% Task 1 %
%% Define a predicate completegrid(S) that holds for a sub-grid definition, if all cells of the 9x9
%% time grid are defined by the sub-grid definition (i.e., sub-grids do not overlap and the union of all
%% subgrids form the 9x9 grid). Find either a counting argument or set argument, to define your predicate.

%% need to get this to fail where |rows| < 9 

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

compute_grid([]).
compute_grid([H|T]) :- 
	length(H, Row_size), 
	Row_size =:= 9,
	complete_row(H, T),
	compute_grid(T).

completegrid([H|T]) :-
	length([H|T], Grid_size), %% Check to make sure grid has 9 lists
	Grid_size =:= 9,
	compute_grid([H|T]).

% Task 2 %
%% Define a predicate contiguousregion(S) that holds for a definition of a region, if the region is
%% contiguous (i.e., don’t split into two regions with no connection via a grid cell)

%% Predicate to find neighbour if the neighbour of the cell isn't obvious from the previous cells grid.
%% It recursively goes through the remaining cells which have not been checked and check if they're 
%% part of the grid that is valid, as well as checking if the cell that is not immediately obvious as to
%% whether or not it is valid, whether this cell is valid too. 
find_prev([H|T], Heads) :-
	H = [A|B], % A is the row position
	B = [C|[]], % C is the column position
	Ap is A+1, Cm is C-1, Am is A-1, Cp is C+1,
	%% -+1 to each entry [i,j] to get neighbours
	Cell_left = [A|[Cm]],
	Cell_right = [A|[Cp]],
	Cell_top = [Am|[C]],
	Cell_bottom = [Ap|[C]],
		(
		%% Check if it's neighbour is in our Heads list
		member(Cell_left, Heads), ! ; 
		member(Cell_right, Heads), ! ;
		member(Cell_top, Heads), ! ; 
		member(Cell_bottom, Heads), ! ;
		(length(Heads, Head_size),
				Head_size =:= 0), ! ;
		(member(H, [H|T]), find_prev(T, Heads), !)
	).

% [i,j] must be able to find a neighbour that is either [i +- 1, j +- 1], (=1 cant -, =9 cant +)
% for all [i, j]t
find_neighbour([], _, _).
find_neighbour([H|T], Hp, Tp) :- 
	H = [A|B], % A is the row position
	B = [C|[]], % C is the column position
	Ap is A+1, Cm is C-1, Am is A-1, Cp is C+1,
	Cell_left = [A|[Cm]],
	Cell_right = [A|[Cp]],
	Cell_top = [Am|[C]],
	Cell_bottom = [Ap|[C]],
	append([H], Hp, Temp_heads), %% All our previous cells and heads appened to Temp_heads
	remove_head(Temp_heads, Heads), %% Remove our head so it won't automatically be true
	(
		(length(Heads, Head_size), %% If the first case where our Heads is []
				Head_size =:= 0), ! ;
		member(Cell_left, Heads), ! ; %% Using cut (!) because if we find it's a member then we're done -- no need to continue proof-finding
		member(Cell_right, Heads), ! ;
		member(Cell_top, Heads), ! ; 
		member(Cell_bottom, Heads), ! ;
		(
			(
				member(Cell_left, [H|T]), ! ; 
				member(Cell_right, [H|T]), ! ;
				member(Cell_top, [H|T]), ! ; 
				member(Cell_bottom, [H|T]), ! 
			),
		find_prev(T, Heads))
	),
	find_neighbour(T, Temp_heads, Tp).

contiguousgrid([H|T]) :- 
	is_set([H|T]), %% check for duplicates. According to EDlms either checking or not checking is fine as long as it yields contiguous when valid
	length([H|T], Row_size),
	Row_size =:= 9, %% must have 9 cells
	find_neighbour([H|T], [], T).