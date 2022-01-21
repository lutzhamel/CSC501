% prove that the value of y is equal to 6 when 
% following program p,
%
%        assign(x,3) seq 
%        assign(y,1) seq 
%        whiledo(le(2,x),
%                assign(y,mult(y,x)) seq 
%                assign(x,sub(x,1))
%        )
%
% is run in the context of any state.
%
% We need to prove
%
% (forall s)(exists SF)[sem(p,s,SF)^lookup(y,SF,6)]

% load semantics
:- [preamble].

% define our program predicate
program(assign(x,3) seq 
	assign(y,1) seq 
        whiledo(le(2,x),
                assign(y,mult(y,x)) seq 
                assign(x,sub(x,1)))).

% proof
:- program(P), sem(P,s,SF), lookup(y,SF,6).
