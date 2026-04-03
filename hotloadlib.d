import std;
import core.stdc.stdlib;
import core.sys.posix.dlfcn;
version(D_OpenD){
	enum compiler="opend -shared -of=";
} else {
	version(DigitalMars) enum compiler="dmd -shared -of=";
	version(LDC) enum compiler="ldc -shared -of=";
}
//unittest{
//	compiler.writeln;
//}
bool maxwatch(T,S)(ref T a,T b,S c){//todo revist the concept, I think theres more here
	if(a+c>=b){return false;}
	a=b;
	return true;
}
//void maxwatchb(T,S)(ref T a,T b,S c){
//	{return false;}
//	a=b;
//	return true;
//}
//unittest{
//	int lastmax=int.min;
//	foreach(i;[1,2,3,102,205,260,500]){
//		"---".writeln;
//		lastmax.writeln;
//		lastmax.maxwatcha(i,100).writeln(i);
//	}
//}


template Stringof(alias A){enum Stringof=__traits(identifier,A);}//https://github.com/dlang/dmd/issues/19266
enum PATH=__FILE_FULL_PATH__[0..$-__FILE__.length];//todo move to header and fix import to be relitive
mixin template hotloadImport(string file,alias mark="hotload",Duration iolimit=dur!"msecs"(500)){
	import std;
	import core.stdc.stdlib;
	import core.sys.posix.dlfcn;
	template impl(string _:file){
		mixin("import "~file~";");
		alias functions=Filter!(isCallable,getSymbolsByUDA!(mixin(file),mark));
		static assert(functions.length!=0,"no functions detected, add a `@\"hotload\":`");
		bool considercompiling(){
			static SysTime lastio, lastmodified;
			return maxwatch(lastio,Clock.currTime(),iolimit) && maxwatch(lastmodified,(file~".d").timeLastModified,dur!"msecs"(0));
		}
		enum filepath=PATH~file~".so";
		template hotload__(alias F){
		auto hotload__(T...)(T args){
			void* handle;//copyed from outside scope, what was I thinking before?
			if(considercompiling){compile(file);}
			handle=dlopen(&filepath[0],RTLD_LAZY);
			assert(handle!=null,dlerror.to!string);
			typeof(&F) call=cast(typeof(&F)) dlsym(handle,F.mangleof);
			scope(exit) dlclose(handle);//does this do anything?
			return call(args);
		}}
	}
	static foreach(A;impl!file.functions){
		pragma(msg,Stringof!A);
		mixin("alias "~Stringof!A~"=impl!file.hotload__!A;");
	}
}
void system_(immutable(char)* c){
	c.to!string.writeln;
	system(c);
}
void compile(string file){
	//enum compiler="opend -shared -of=";
	system_(&(compiler~file~".so "~file~".d\0")[0]);
}
//---
void repl(string[] imports,string udamarker="data",string file="data")(string code){
	mixin("import "~file~";");
	alias datas=getSymbolsByUDA!(mixin(file),udamarker);
	File f=File("repltemp.d","w");
	foreach(s;imports){
		f.writeln("import "~s~";");
	}
	f.writeln("import "~file~";");
	f.write("extern(C) void thefunction(");
	//static foreach(A;datas){
	//	f.write("ref typeof(",A.stringof,") ",A.stringof,",");
	//}
	f.writeln("){");
	f.writeln(code);
	f.writeln("}");
	f.close;
	//---
	compile("repltemp");
	enum filepath=PATH~"repltemp.so";
	auto handle=dlopen(&filepath[0],RTLD_LAZY);
	assert(handle!=null,dlerror.to!string);
	extern(C) static void thefunction(){//ref typeof(datas) args){
		//static foreach(T;args){
		//	T.writeln;
	}//}
	typeof(&thefunction) F;
	if(handle==null){
		F=&thefunction;
	} else {
		F=cast(typeof(&thefunction)) dlsym(handle,"thefunction");
		assert(handle!=null,dlerror.to!string);
	}
	if(F==null){F=&thefunction;}
	F();//datas);
	dlclose(handle);
	//TODO delete .so
}
