package components.macros;

#if !display
class GitCommit
{
	public static macro function getGitHash():haxe.macro.Expr.ExprOf<String>
	{
		#if !display
		var pos = haxe.macro.Context.currentPos();

		var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);
		if (process.exitCode() != 0)
		{
			haxe.macro.Context.info("Shit, Couldn't determine git commit, is this a proper git repo?", pos);
		}

		var commitHash:String = process.stdout.readLine().substr(0, 7);

		process.close();

		trace('Git Commit ID: $commitHash');

		return macro $v{commitHash};
		#else
		return macro $v{''};
		#end
	}

	public static macro function getGitBranch():haxe.macro.Expr.ExprOf<String>
	{
		#if !display
		var pos = haxe.macro.Context.currentPos();

		var process = new sys.io.Process('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
		if (process.exitCode() != 0)
		{
			haxe.macro.Context.info("Shit, Couldn't determine git commit, is this a proper git repo?", pos);
		}

		var commitHash:String = process.stdout.readLine();

		process.close();

		trace('Git Branch: $commitHash');

		return macro $v{commitHash};
		#else
		return macro $v{''};
		#end
	}

	/**
	 * Get whether the local Git repository is dirty or not.
	 */
	public static macro function getGitHasLocalChanges():haxe.macro.Expr.ExprOf<Bool>
	{
		#if !display
		var pos = haxe.macro.Context.currentPos();
		var branchProcess = new sys.io.Process('git', ['status', '--porcelain']);

		if (branchProcess.exitCode() != 0)
		{
			haxe.macro.Context.info("Shit, Couldn't determine git commit, is this a proper git repo?", pos);
		}

		var output:String = '';
		try
		{
			output = branchProcess.stdout.readLine();
			branchProcess.close();
		}
		catch (e)
		{
			if (e.message == 'Eof') {}
			else
			{
				throw e;
			}
		}
		trace('Git Status Output: ${output}');
		return macro $v{output.length > 0};
		#else
		return macro $v{true};
		#end
	}
}
#end