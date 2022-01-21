% prove that
%     assign(x,1) seq assign(y,2) ~ assign(y,2) seq assign(x,1)
%
% We need to show that
% (forall s,z)(exist S0,S1,V0,V1)
%     [sem(assign(x,1) seq assign(y,2),s,S0)^
%      sem(assign(y,2) seq assign(x,1),s,S1)^
%      lookup(z,S0,V0) ^ lookup(z,S1,V1) ^ is(V0,V1)]
% assume lookup(z,s,vz)

%load semantics
:- [preamble].

% assumption
:- assert(lookup(z,s,vz)).

:- >>> 'we show equivalence by case analysis on z' .
:- >>> 'case z = x'.
:- sem(assign(x,1) seq assign(y,2),s,S0),
   sem(assign(y,2) seq assign(x,1),s,S1),
   lookup(x,S0,V0),
   lookup(x,S1,V1),
   V0=V1.

:- >>> 'case z = y'.
:- sem(assign(x,1) seq assign(y,2),s,S0),
   sem(assign(y,2) seq assign(x,1),s,S1),
   lookup(y,S0,V0),
   lookup(y,S1,V1),
   V0=V1.

:- >>> 'case z =/= x and z =/= y'.
:- sem(assign(x,1) seq assign(y,2),s,S0),
   sem(assign(y,2) seq assign(x,1),s,S1),
   lookup(z,S0,V0),
   lookup(z,S1,V1),
   V0=V1.
