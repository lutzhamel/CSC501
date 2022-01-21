% proof-aexp-induction.pl

:- ['preamble.pl'].

:- >>> 'show that all arithmetic operations terminate'.
:- >>> '  (forall a)(forall s)(exists K)[(a,s)-->>K]'.
:- >>> 'we prove this by structural induction on arithmetic expressions'.

% load semantics
:- ['sem.pl'].

:- >>> 'base case: variables'.
%%% assumption: lookup will always produce a value
:- asserta(lookup(x,s,vx)).
%%% proof
:- (x,s)-->>vx.
%%% clean up
:- retract(lookup(x,s,vx)).

:- >>> 'base case: integer values'.
%%% assumption: n is an integer
:- asserta(int(n)).
%%% proof
:- (n,s)-->>n.
%%% clean up
:- retract(int(n)).

:- >>> 'inductive step: add(a0,a1)'.
%%% inductive hypotheses
:- asserta((a0,s)-->>va0).
:- asserta((a1,s)-->>va1).
%%% induction step
:- (add(a0,a1),s)-->>va0+va1.
%%% clean up
:- retract((a0,s)-->>va0).
:- retract((a1,s)-->>va1).

:- >>> 'the remaining operators can be proved similarly'.

