% sum.pl
:-['preamble.pl'].
:-['sem.pl'].

:- >>> 'define the parts of our program'.
init(assign(i,0) seq assign(p,0)).
guard(not(eq(i,n))).
body(assign(i,add(i,1)) seq assign(p,add(p,i))).

:- >>> 'define our sum operation'.
:- dynamic sum/2.

sum(0,0).

sum(X,Y) :- 
    T1 is X-1,
    sum(T1,T2), 
    Y is X+T2.

:- >>> 'first proof obligation'.
:- >>> 'assume precondition'.
:- asserta(lookup(n,s,vn)).
:- >>> 'proof the invariant'.
:- init(I),(I,s) -->> Q,lookup(p,Q,VP),lookup(i,Q,VI), sum(VI,VP).
:- retract(lookup(n,s,vn)).

:- >>> 'second  proof obligation'.
:- >>> 'assume invariant on s'.
:- asserta(lookup(p,s,vp)).
:- asserta(lookup(i,s,vi)).
:- asserta(sum(vi,vp)).
% implies
:- asserta(sum(vi+1,vp+(vi+1))).
:- >>> 'assume guard on s'.
:- asserta((not(eq(i,n)),s) -->> true).
:- >>> 'proof the invariant on Q'.
:- body(Bd),(Bd,s) -->> Q,lookup(p,Q,VP),lookup(i,Q,VI), sum(VI,VP).
:- retract(lookup(p,s,vp)).
:- retract(lookup(i,s,vi)).
:- retract(sum(vi,vp)).
:- retract(sum(vi+1,vp+(vi+1))).
:- retract((not(eq(i,n)),s) -->> true).

:- >>> 'third  proof obligation'.
:- >>> 'assume the invariant on s'.
:- asserta(lookup(p,s,vp)).
:- asserta(lookup(i,s,vi)).
:- asserta(sum(vi,vp)).
:- >>> 'assume NOT guard on s'.
:- asserta((not(eq(i,n)),s) -->> not(true)).
% implies
:- asserta((eq(i,n),s) -->> true).
% implies
:- asserta(sum(vn,vp)).
:- >>> 'prove postcondition on s'.
:- lookup(p,s,VP),sum(vn,VP).
:- retract(lookup(p,s,vp)).
:- retract(lookup(i,s,vi)).
:- retract(sum(vi,vp)).
:- retract((not(eq(i,n)),s) -->> not(true)).
:- retract((eq(i,n),s) -->> true).
:- retract(sum(vn,vp)).


