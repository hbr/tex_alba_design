Definition exFalso (p: False) {A: Type}: A :=
    match p with end.


Definition Predicate (A: Type): Type :=
    A -> Prop.

Definition Endorelation (A: Type): Type :=
    A -> A -> Prop.


Inductive Equal {A: Type} (a: A): Predicate A :=
    identical: Equal a a.


Definition Natural: Type := nat.


Theorem naturalInduction
    {P: Predicate Natural}
    (zero: P O)
    (next: forall n, P n -> P (S n))
    : forall {n}, P n.
Proof
    fix f {n} :=
        match n with
        | O => zero
        | S i =>
            next i f
        end.



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
        fun le => identical O
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
        
