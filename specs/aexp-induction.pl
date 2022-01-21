% show that all arithmetic operations terminate
%   (forall a)(forall s)(exists K)[sem(a,s,K]
% we prove this by structural induction on Aexp

% load semantics
:- [preamble].

:- >>> 'base case: variables'.
%%% assumption: lookup will always produce a value
:- asserta(lookup(x,s,vx)).
%%% proof
:- sem(x,s,vx).
%%% clean up
:- retract(lookup(x,s,vx)).

:- >>> 'base case: integer values'.
%%% assumption: n is an integer
:- asserta(int(n)).
%%% proof
:- sem(n,s,n).
%%% clean up
:- retract(int(n)).

:- >>> 'inductive step: add(a0,a1)'.
%%% inductive hypotheses
:- asserta(sem(a0,s,va0)).
:- asserta(sem(a1,s,va1)).
%%% induction step
:- sem(add(a0,a1),s,va0+va1).
%%% clean up
:- retract(sem(a0,s,va0)).
:- retract(sem(a1,s,va1)).

:- >>> 'the remaining operators can be proved similarly'.

