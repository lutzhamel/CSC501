% fact.pl
:-['preamble.pl'].
:-['sem.pl'].

:- >>> 'define the parts of our program'.
init(assign(i,1) seq assign(z,1)).
guard(not(eq(i,n))).
body(assign(i,add(i,1)) seq assign(z,mult(z,i))).

:- >>> 'define our fact operation'.
:- dynamic fact/2.

fact(1,1).

fact(X,Y) :- 
    T1 is X-1,
    fact(T1,T2), 
    Y is X*T2.

:- >>> 'first proof obligation'.
:- >>> 'assume precondition'.
:- asserta(lookup(n,s,vn)).
:- >>> 'prove the invariant'.
:- init(I),(I,s) -->> Q,lookup(z,Q,VZ),lookup(i,Q,VI), fact(VI,VZ).
:- retract(lookup(n,s,vn)).

:- >>> 'second  proof obligation'.
:- >>> 'assume invariant on s'.
:- asserta(lookup(z,s,vz)).
:- asserta(lookup(i,s,vi)).
:- asserta(fact(vi,vz)).
% implies
:- asserta(fact(vi+1,vz*(vi+1))).
:- >>> 'assume guard on s'.
:- asserta((not(eq(i,n)),s) -->> true).
:- >>> 'prove the invariant on Q'.
:- body(Bd),(Bd,s) -->> Q,lookup(z,Q,VZ),lookup(i,Q,VI), fact(VI,VZ).
:- retract(lookup(z,s,vz)).
:- retract(lookup(i,s,vi)).
:- retract(fact(vi,vz)).
:- retract(fact(vi+1,vz*(vi+1))).
:- retract((not(eq(i,n)),s) -->> true).

:- >>> 'third  proof obligation'.
:- >>> 'assume the invariant on s'.
:- asserta(lookup(z,s,vz)).
:- asserta(lookup(i,s,vi)).
:- asserta(fact(vi,vz)).
:- >>> 'assume NOT guard on s'.
:- asserta((not(eq(i,n)),s) -->> not(true)).
% implies
:- asserta((eq(i,n),s) -->> true).
% implies
:- asserta(fact(vn,vz)).
:- >>> 'prove postcondition on s'.
:- lookup(z,s,VZ),fact(vn,VZ).
:- retract(lookup(z,s,vz)).
:- retract(lookup(i,s,vi)).
:- retract(fact(vi,vz)).
:- retract((not(eq(i,n)),s) -->> not(true)).
:- retract((eq(i,n),s) -->> true).
:- retract(fact(vn,vz)).


