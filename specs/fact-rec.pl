:- ['sem-func.pl'].

program(fun(fact,
	    [i],
	    put(i) seq
	    var(result) seq
	    if(eq(i,0),
	       assign(result,1),
	       assign(result,mult(i,call(fact,[assign(i,sub(i,1))])))),
	    result) seq
	var(x) seq
	assign(x,call(fact,[assign(i,3)])) seq
	put(x)).

:- program(P),(P,s) -->> SF.
