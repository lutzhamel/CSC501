% double.pl
:-['sem.pl'].

:- >>> 'show that program P="assign(z,add(z,z)))"'.
:- >>> 'satisfies the program specification:'.
:- >>> ' (p,s) -->> Q,lookup(z,s,V1),lookup(z,Q,V2),V2 = 2*V1'.

program(assign(z,add(z,z))).

:- asserta(lookup(z,s,vz)).                                                                        
:- asserta(2*I xis I+I). % property of integers                                               
                                                                                                   
:- program(P),
      (P,s) -->> Q,
      lookup(z,s,V1),                                                                              
      lookup(z,Q,V2),
      V2 = 2 * V1.
