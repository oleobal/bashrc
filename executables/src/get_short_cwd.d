module get_short_cwd;

import std.stdio;
import std.algorithm.searching:canFind;
import std.array:split,join;


string get_short_cwd(string cwd)
{
	auto breakchars=".-_";
	auto whitespace=" \t\n";
	auto caps="QWERTYUIOPASDFGHJKLZXCVBNM";
	string[] result;
	
	auto words = cwd.split('/');
	
	foreach(w;words[0..$-1])
	{
		auto wResult="";
		auto i=0;
		
		while (i<w.length)
		{
			while(i<w.length && breakchars.canFind(w[i]))
			{
				if (wResult.length == 0 || w[i] != wResult[$-1])
					wResult~=w[i];
				i++;
			}
			
			if (i>=w.length)
				break;
			
			if (caps.canFind(w[i]) && (i==0 || !caps.canFind(w[i-1])))
				wResult~=w[i];
			else if (
				   (i==0 || breakchars.canFind(w[i-1]))
				&& (!whitespace.canFind(w[i])))
				wResult~=w[i];
			
			i++;
		}
		result~=wResult;
	}
	return result.join("/")~"/"~words[$-1];
}

int main(string[] args)
{
	if (args.length != 2)
		return 1;
	
	
	get_short_cwd(args[1]).writeln;
	
	return 0;
}
