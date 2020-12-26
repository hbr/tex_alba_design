Definition exFalso (p: False) {A: Type}: A :=
    match p with end.


Definition Predicate (A: Type): Type :=
    A -> Prop.

Definition Endorelation (A: Type): Type :=
    A -> A -> Prop.


Inductive Equal {A: Type} (a: A): Predicate A :=
    identical: Equal a a.

Arguments identical {_ _}.

Theorem equalApply
    {A B: Type} {a b: A}
    (eq: Equal a b)
    (f: A -> B)
    : Equal (f a) (f b).
Proof
    match eq with
    | identical =>
        identical
    end.



Inductive Exist {A: Type} (P: Predicate A): Prop :=
    exist x: P x -> Exist P.

Arguments exist {_ _ _} _.


Inductive Refine {A: Type} (P: Predicate A): Type :=
    refine x: P x -> Refine P.

Arguments refine {_ _} _ _.





Inductive Decision2 (A B: Prop): Type :=
    | left: A -> Decision2 A B
    | right: B -> Decision2 A B.



Definition Decision (A: Prop): Type :=
    Decision2 A (~A).


Definition Decider {A: Type} (P: Predicate A): Type :=
    forall x, P x.






Inductive Terminating {A: Type} (R: Endorelation A): Predicate A :=
    terminate x:
        (forall y, R x y -> Terminating R y)
        -> Terminating R x.

Arguments terminate {_ _ _} _.

Definition progress
    {A: Type} {x y: A} {R: Endorelation A}
    (term: Terminating R x)
    (rXY: R x y)
    : R x y -> Terminating R y
:=
    match term with
    | terminate f =>
        f _
    end.





Definition Natural: Type := nat.


Theorem naturalInduction
    {P: Predicate Natural}
    (zero: P O)
    (next: forall n, P n -> P (S n))
    : forall {n}, P n.
Proof
    fix f {n} :=
        match n with
        | O =>
            zero
        | S i =>
            next i f
        end.






(* Order Relation
   --------------
*)

Inductive LessEqual: Endorelation Natural :=
| lessEqualStart {n}: LessEqual O n
| lessEqualStep {n m} (le: LessEqual n m): LessEqual (S n) (S m).



Theorem lessEqualInduction
    {R: Endorelation Natural}
    (start: forall i, R O i)
    (step: forall i j, LessEqual i j -> R i j -> R (S i) (S j))
    : forall i j, LessEqual i j -> R i j.
Proof
    fix f {i j} le :=
        match le with
        | lessEqualStart => start _
        | lessEqualStep le0 => step _ _ le0 (f le0)
        end.




Theorem lessEqualDiscriminate {n: Natural}: LessEqual (S n) O -> False.
Proof
    @lessEqualInduction
        (fun n m =>
            match n with
            | O => True
            | S _ =>
                match m with
                | O => False
                | S _ => True
                end
            end)
        (fun _ => I)
        (fun _ _ _ _ => I)
        _ _.




Theorem lessEqualInvert {n m: Natural}
            : LessEqual (S n) (S m) -> LessEqual n m.
Proof
    @lessEqualInduction
        (fun n m =>
            match n with
            | O => True
            | S i =>
                match m with
                | O => True
                | S j => LessEqual i j
                end
            end)
        (fun _ => I)
        (fun _ _ le _ => le)
        _ _.




Theorem lessEqualZeroIsZero {a: Natural}: LessEqual a O -> Equal a O.
Proof
    match a with
    | O =>
        fun le => identical
    | S i =>
        fun le =>
            exFalso (lessEqualDiscriminate le)
    end.


Theorem lessEqualReflexive {n: Natural}: LessEqual n n.
Proof
    @naturalInduction
        (fun n => LessEqual n n)
        lessEqualStart
        (fun n le => lessEqualStep le)
        n.



(* Strict Order Relation
   ---------------------
*)

Definition LessThan: Endorelation Natural :=
    fun x y => LessEqual (S x) y.




Theorem leToLt {a b: Natural}: LessEqual a b -> ~ Equal a b -> LessThan a b.
Proof
    @lessEqualInduction
        (fun a b => ~ Equal a b -> LessThan a b)

        (fun b =>
            match b with
            | O =>
                fun notEqZeroZero =>
                    exFalso (notEqZeroZero identical)
            | S i =>
                fun _ =>
                    lessEqualStep lessEqualStart
            end)

        (fun a b leAB notEqABToLtAB notEqSuccASuccB =>
            lessEqualStep
                (notEqABToLtAB
                    (fun eqAB =>
                        notEqSuccASuccB (equalApply eqAB S))
                ))
        a
        b.



Theorem leToNotLt {a b: Natural}: LessEqual a b -> ~ LessThan b a.
Proof
    @lessEqualInduction
        (fun a b => ~ (LessThan b a))
        (fun _ => lessEqualDiscriminate)
        (fun a b _ notLtAB ltSuccASuccB =>
            notLtAB (lessEqualInvert ltSuccASuccB))
        a
        b.






(* Order Predicates
   ----------------
*)

Definition LowerBound (P: Predicate Natural) (x: Natural): Prop :=
    forall y, P y -> LessEqual x y.



Definition Least (P: Predicate Natural) (x: Natural): Prop :=
    LowerBound P x /\ P x.


(*
Theorem nextLowerBound
    {P: Predicate Natural} {n: Natural}
    (lb: LowerBound P n)
    (notPN: ~ P n)
    : LowerBound P (S n).
Proof
    fun i pI => _.
*)


(* Unbounded Search
   ----------------
*)
Section unbounded.
    Variable P: Predicate Natural.
    Variable p: Decider P.
    Variable e: Exist P.
    Let R: Endorelation Natural :=
        fun x y => LessThan x y /\ LowerBound P y.

End unbounded.
        
