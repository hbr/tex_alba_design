Definition Predicate (A: Type): Type :=
    A -> Prop.


Definition Top {A: Type}: Predicate A :=
    fun _ => True.


Inductive Refine {A: Type} (P: Predicate A): Type :=
    refine x: P x -> Refine P.


Arguments refine {_ _}.




Definition HRelation (S A: Type): Type :=
    S -> A -> S -> Prop.




(** 'Hoare Pre Post'

A computation which starts in a state 's1' satisfying 'Pre s1' and computes a
value 'x' and ends in a state 's2' satisfying 'Post s1 x s2'.

The state type 'S' and the return type 'A' are implicitely defined by the
functions 'Pre' and 'Post'.

*)
Definition Hoare
    {S A: Type}
    (Pre: Predicate S)
    (Post: HRelation S A)
    : Type
:=
    forall s0,
        Pre s0
        -> Refine (fun p: A * S => Post s0 (fst p) (snd p)).



Definition pure
    {S A: Type}
    : forall x, @Hoare S A Top (fun s0 y s1 => s0 = s1 /\ y = x)
:=
    fun x s top =>
        refine
            (x, s)
            (conj eq_refl eq_refl: s = s /\ x = x).



Definition bind
    {S A B: Type}
    {P1: Predicate S}
    {Q1: HRelation S A}
    {P2: A -> Predicate S}
    {Q2: A -> HRelation S B}
:
    (Hoare P1 Q1)
    ->
    (forall x, Hoare (P2 x) (Q2 x))
    ->
    Hoare
        (fun s1 => P1 s1 /\ forall x s2, Q1 s1 x s2 -> P2 x s2)
        (fun s1 y s3 => exists x, exists s2, Q1 s1 x s2 /\ Q2 x s2 y s3)
:=
    fun c1 c2 s1 cond =>
    match cond with
    | conj pre1 post1 =>
        match c1 s1 pre1 with
        | refine (x,s2) proof1 =>
            match c2 x s2 (post1 x s2 proof1) with
            | refine (y,s3) proof2 =>
                refine
                    (y,s3)
                    (ex_intro _ x (ex_intro _ s2 (conj proof1 proof2))
                    :
                    exists x s2, Q1 s1 x s2 /\ Q2 x s2 y s3)
            end
        end
    end.







(* A different model
   =================
*)

Definition Transformer (S A: Type) (P: Predicate S): Type
:=
    forall s, P s -> A -> S.


Inductive
    IOAction (S A: Type) (Pre: Predicate S): Transformer S A Pre -> Type
:=
    mkIO f: IOAction S A Pre f.
