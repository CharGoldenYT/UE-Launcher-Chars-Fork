package components;

import components.macros.GitCommit;

class Constants
{
	public static var VERSION(get, null):String;

	static function get_VERSION():String
	{
		return
			'1.0\nGit Commit ${GitCommit.getGitHash()}${'\nBranch: ' + GitCommit.getGitBranch()}${if (GitCommit.getGitHasLocalChanges()) '\nMODIFIED' else ''}\nChar\'s Custom Build';
	}
}