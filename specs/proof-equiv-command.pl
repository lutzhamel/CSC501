% proof-equiv-command.pl

:- ['preamble.pl'].

:- >>> 'prove that'.
:- >>> '   assign(x,1) seq assign(y,2) ~ assign(y,2) seq assign(x,1)'.

% We need to show that
% (forall s,z)(exist S0,S1,V0,V1)
%     [(assign(x,1) seq assign(y,2),s)-->>S0 ^
%      (assign(y,2) seq assign(x,1),s)-->>S1 ^
%      lookup(z,S0,V0) ^ lookup(z,S1,V1) ^ =(V0,V1)]
% assume lookup(z,s,vz)

%load semantics
:- ['sem.pl'].

% assumption
:- asserta(lookup(z,s,vz)).

:- >>> 'we show equivalence by case analysis on z' .
:- >>> 'case z = x'.
:- ((assign(x,1) seq assign(y,2)),s)-->>S0,
   ((assign(y,2) seq assign(x,1)),s)-->>S1,
   lookup(x,S0,V0),
   lookup(x,S1,V1),
   V0=V1.

:- >>> 'case z = y'.
:- ((assign(x,1) seq assign(y,2)),s)-->>S0,
   ((assign(y,2) seq assign(x,1)),s)-->>S1,
   lookup(y,S0,V0),
   lookup(y,S1,V1),
   V0=V1.

:- >>> 'case z =/= x and z =/= y'.
:- ((assign(x,1) seq assign(y,2)),s)-->>S0,
   ((assign(y,2) seq assign(x,1)),s)-->>S1,
   lookup(z,S0,V0),
   lookup(z,S1,V1),
   V0=V1.
