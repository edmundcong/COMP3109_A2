% Task 1 %
%% Define a predicate completegrid(S) that holds for a sub-grid definition, if all cells of the 9x9
%% time grid are defined by the sub-grid definition (i.e., sub-grids do not overlap and the union of all
%% subgrids form the 9x9 grid). Find either a counting argument or set argument, to define your predicate.

remove_head([_|Tail], Tail). %remove first element and return tail

to_pairs([], []).
to_pairs([A, B | Tb], [[A, B] | Ta]) :- to_pairs(Tb, Ta).

complete_row([], _).
complete_row([H|T], Tail) :- 
	union([H|T], Tail, N),
	remove_head(N, Tprime),
	H = [A|B],
	A > 0, A < 10, B > 0, B < 10,
	flatten(Tprime, Flist),
	to_pairs(Flist, Plist),
	intersection([H], Plist, K),
	length(K, 0),
	complete_row(T, Tail).

completegrid([]).
completegrid([H|T]) :- 
	length(H, Row_size), 
	Row_size =:= 9,
	complete_row(H, T),
	completegrid(T).

% Task 2 %
%% Define a predicate contiguousregion(S) that holds for a definition of a region, if the region is
%% contiguous (i.e., don’t split into two regions with no connection via a grid cell)
contiguousgrid([H|T]) :- 
	write([H|T]).