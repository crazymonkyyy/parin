import std;
import core.stdc.stdlib;
import core.sys.posix.dlfcn;
int i;
ushort j;
struct S{
    int[7] i;
}
S s;

alias A=AliasSeq!(j,s,i);
void foo(ref ushort j, ref S,ref int i){
    j=1337;
    i=420;
}
void bar(ref typeof(A) a){
    a[0].writeln;
    a[2].writeln;
}
void foobar(ref typeof(A) a){
    a[2]=7;
}
void barfoo(ref ushort j, ref S,ref int i){
    i.writeln;
    j.writeln;
}

unittest{
    auto F=&foo;
    F=cast(typeof(F))dlsym(null,foo.mangleof);
    F(A);
    F=cast(typeof(F))dlsym(null,bar.mangleof);
    F(A);
    F=cast(typeof(F))dlsym(null,foobar.mangleof);
    F(A);
    F=cast(typeof(F))dlsym(null,bar.mangleof);
    F(A);
    F=cast(typeof(F))dlsym(null,barfoo.mangleof);
    F(A);
}
