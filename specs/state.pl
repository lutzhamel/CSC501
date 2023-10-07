% state.pl
% version 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% our states are represented as list-like, right-associative structures
%  state((x,10)#(y,25)#s0)
%
% NOTE: the 'state' functor is necessary otherwise the prolog parser
% will not parse the infix # constructor correctly.

:- op(1200,xfy,#). % internal state representation right-associative list-like

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'lookup(+Variable)' looks up
% the variable in the state and returns its bound value.
:- dynamic lookup/1.                % modifiable predicate

state(s0):: lookup(_) >--> 0.  % looking up anything in initial state s0 produces 0

state((X,Val)):: lookup(X) >--> Val.

state((X,Val)#_):: lookup(X) >--> Val.

state(_#Rest):: lookup(X) >--> Val :- 
    state(Rest):: lookup(X) >--> Val.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'put(+Variable,+Valuee)' adds
% a binding term to the state.
:- dynamic put/2.                   % modifiable predicate

state(S):: put(X,Val) >--> state((X,Val)#S).

