<?php
/**
 * @link http://www.yiiframework.com/
 * @copyright Copyright (c) 2008 Yii Software LLC
 * @license http://www.yiiframework.com/license/
 */

/**
 * @author Qiang Xue <qiang.xue@gmail.com>
 * @since 2.0
 */
class Subsplit
{
	const GITHUB_BASE_URL = 'https://api.github.com';

	public $git;
	public $repo;
	public $root;
	public $subsplits;
	public $branches;
	public $githubToken;
	public $lastSync;

	public function __construct($repo, $root, array $branches, array $subsplits, $githubToken, $git = 'git')
	{
		$this->repo = $repo;
		$this->root = $root;
		$this->subsplits = $subsplits;
		$this->branches = $branches;
		$this->githubToken = $githubToken;
		$this->git = $git;

		if (!is_dir("$root/.subsplit/.git")) {
			throw new Exception("No git repo was found in '$root'.");
		}

		$syncFile = $this->getSyncFile();
		if (is_file($syncFile)) {
			$this->lastSync = require($syncFile);
		} else {
			$this->lastSync = array('hashes' => array(), 'subsplits' => array());
		}
	}

	public function update($tag = null)
	{
		$subtreeCache = "{$this->root}/.subsplit/.git/subtree-cache";
		if (is_dir($subtreeCache)) {
			$command = "rm -rf $subtreeCache";
			echo "Executing command: $command\n";
			$return = 0;
			passthru($command, $return);
			if ($return != 0) {
				throw new Exception("Flushing subtree cache failed (return value $return).");
			}
		}

		foreach ($this->branches as $branch) {
			echo "checking last sync for branch '$branch'...\n";
			$lastHash = isset($this->lastSync['hashes'][$branch]) ? $this->lastSync['hashes'][$branch] : false;
			$hash = $this->getHash($branch);
			echo "  last hash    '$lastHash'\n";
			echo "  current hash '$hash'\n";
			if ($lastHash === false || $tag !== null) {
				$splits = $this->subsplits;
			} elseif ($lastHash !== $hash) {
				$splits = $this->getChangedSubsplits($hash, $lastHash);
			} else {
				$splits = array();
			}

			foreach ($this->subsplits as $name => $path) {
				if (!isset($this->lastSync['subsplits'][$name])) {
					$splits[$name] = $path;
				}
			}

			if (!empty($splits)) {
				$this->updateSubsplits($branch, $splits, $hash, $tag);
			} else {
				echo "No updates found on branch: $branch\n";
			}
		}
	}

	protected function getChangedSubsplits($hash, $lastHash)
	{
		$diff = $this->queryGithub("/repos/{$this->repo}/compare/$lastHash...$hash");
		echo "checking diff with " . count($diff['files']) . " files...\n";

		$subsplits = array();

		// Github API limits files to 300 even if there are more
		// The API does not provide an indicator that the list is limited
		// If we see 300 files, we trigger a subsplit without checking files
		if (count($diff['files']) >= 300) {
			echo "diff contains >= 300 files, trigger subsplit for all subdirs.\n";
			foreach ($this->subsplits as $path => $repo) {
				$subsplits[$path] = $repo;
			}
			return $subsplits;
		}
		foreach ($diff['files'] as $file) {
			$filename = $file['filename'];
			foreach ($this->subsplits as $path => $repo) {
				if (strpos($filename, $path) === 0) {
					$subsplits[$path] = $repo;
				}
			}
		}
		return $subsplits;
	}

	protected function updateSubsplits($branch, $subsplits, $hash, $tag)
	{
		foreach ($subsplits as $path => $repo) {
			$subsplits[$path] = "$path:git@github.com:$repo.git";
		}

		if ($tag === null) {
			$pattern = 'cd %s && %s subsplit publish "%s" --update --heads="%s" --no-tags 2>&1';
		} else {
			// $pattern = 'cd %s && %s subsplit publish "%s" --update --heads="%s" --tags="' . $tag . '" 2>&1';
			$pattern = 'cd %s && %s subsplit publish "%s" --update --no-heads --tags="' . $tag . '" 2>&1';
		}

		$command = sprintf($pattern, $this->root, $this->git, implode(' ', $subsplits), $branch);
		echo "Executing command: {$command}\n";
		$return = 0;
		passthru($command, $return);
		if ($return != 0) {
			throw new Exception("Subsplit publish failed (return value $return).");
		}

		$this->lastSync['subsplits'] = array_merge($this->lastSync['subsplits'], $subsplits);
		$this->lastSync['hashes'][$branch] = $hash;
		$syncFile = $this->getSyncFile();
		file_put_contents($syncFile, "<?php\n\nreturn " . var_export($this->lastSync, true) . ";\n");
	}

	protected function getSyncFile()
	{
		return $this->root . '/last-sync.php';
	}

	protected function getHash($branch)
	{
		$data = $this->queryGithub("/repos/{$this->repo}/branches/$branch");
		if (isset($data['commit']['sha'])) {
			return $data['commit']['sha'];
		} else {
			throw new Exception("Unknown data received: " . var_export($data, true));
		}
	}

	protected function queryGithub($url)
	{
		$url = self::GITHUB_BASE_URL . $url;
		echo "Github API request: $url\n";
		$c = curl_init();
                curl_setopt($c, CURLOPT_SSLVERSION, 6);
		curl_setopt($c, CURLOPT_URL, $url);
		curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($c, CURLOPT_CONNECTTIMEOUT, 3);
		curl_setopt($c, CURLOPT_TIMEOUT, 5);
		curl_setopt($c, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2 GTB5');
		curl_setopt($c, CURLOPT_HTTPHEADER, array(
			"Authorization: token {$this->githubToken}",
			'Accept: application/json'
		));
		$response = curl_exec($c);
		$responseInfo = curl_getinfo($c);
		curl_close($c);
		if (intval($responseInfo['http_code']) == 200) {
			return json_decode($response, true);
		} else {
			throw new Exception("Failed to fetch URL: $url (error code {$responseInfo['http_code']}): " . json_encode($responseInfo));
		}
	}
}

