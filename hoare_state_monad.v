Require Import List.
Import ListNotations.

(* Some general definitions
   ========================
*)



Definition Predicate (A: Type): Type :=
    A -> Prop.


Definition Top {A: Type}: Predicate A :=
    fun _ => True.


Inductive Exist2 {A B: Type} (P: A -> B -> Prop): Prop :=
    exist2 a b: P a b -> Exist2 P.

Arguments exist2 {_ _ _ _ _}.


Inductive Pair {A B: Type} (P: A -> B -> Prop): Prop :=
    make_pair a b: P a b -> Pair P.

Arguments make_pair {_ _ _}. (* a and t2 are not implicit. *)


Definition mapPairPredicate
    {A B: Type}
    {P1: A -> B -> Prop}
    {P2: A -> B -> Prop}
    (pair: Pair P1)
    (f: forall a b, P1 a b -> P2 a b)
: Pair P2
:=
    match pair with
    | make_pair a b sat =>
        make_pair a b (f a b sat)
    end.




(* Hoare State Monad
   ====================
*)

Module Hoare_state.
Section hoare_state.
    Variable State: Type.

    Definition Trans (A: Type): Type :=
        State -> A -> State -> Prop.

    Definition TopTrans (A: Type): Trans A :=
        fun _ _ _ => True.


    Definition Hoare
        {A: Type}
        (Q: Predicate State)
        (R: Trans A): Type
    :=
        forall s1,
            Q s1
            -> Pair (fun a s2 => R s1 a s2).


    Definition pure
        {A: Type} (a: A)
    : Hoare Top (fun s1 x s2 => s2 = s1 /\ x = a)
    :=
        fun s1 _ =>
            make_pair a s1 (conj eq_refl eq_refl).



    Definition bind
        {A B: Type}
        {Q1: Predicate State}
        {R1: Trans A}
        {Q2: A -> Predicate State}
        {R2: A -> Trans B}
        (m: Hoare Q1 R1) (f: forall a, Hoare (Q2 a) (R2 a))
    : Hoare
        (fun s1 => Q1 s1 /\ forall a s2, R1 s1 a s2 -> Q2 a s2)
        (fun s1 b s3 => Exist2 (fun a s2 => R1 s1 a s2 /\ R2 a s2 b s3))
    :=
        fun s1 bind_pre =>
            let pre1: Q1 s1 :=
                match bind_pre with
                | conj pre1 _ => pre1
                end
            in
            let pre2 a s2 sat1: Q2 a s2 :=
                match bind_pre with
                | conj _ pre2 => pre2 a s2 sat1
                end
            in
            match m s1 pre1 with
            | make_pair a s2 sat1 =>
                mapPairPredicate
                    (f a s2 (pre2 a s2 sat1))
                    (fun a s2 sat2 => exist2 (conj sat1 sat2))
            end.



    Definition get
    : Hoare Top (fun s1 a s2 => s2 = s1 /\ a = s1)
    :=
        fun s1 _ =>
            make_pair s1 s1 (conj eq_refl eq_refl).


    Definition put
        (s: State)
    : Hoare (A := unit) Top (fun _ _ s2 => s2 = s)
    :=
        fun s1 _ =>
            make_pair tt s eq_refl.


End hoare_state.
End Hoare_state.



(* Second Version of the Hoare state monad
   =======================================
*)
Module Hoare_state2.
Section hoare_state2.
    Variable State: Type.

    Definition Trans (A: Type): Type :=
        State -> A -> State -> Prop.

    Definition TopTrans (A: Type): Trans A :=
        fun _ _ _ => True.


    Definition Hoare {A: Type} (Q: Predicate State) (R: Trans A): Type :=
        forall s1,
            Q s1
            -> Pair (fun a s2 => R s1 a s2).


    Definition pure
        {A: Type} (a: A)
    : Hoare Top (fun s1 x s2 => s2 = s1 /\ x = a)
    :=
        fun s1 _ =>
            make_pair a s1 (conj eq_refl eq_refl).


    (*Definition bind
        {A B: Type}
        {Q1: Predicate State}
        {R1: Trans A}
        {Q2: A -> Predicate State}
        {R2: A -> Trans B}
        (m: Hoare Q1 R1)
        (f: forall a, Hoare (Q2 a) (R2 a))
        (pre2: forall s1 a s2, Q1 s1 -> R1 s1 a s2 -> Q2 a s2)
    : Hoare
        Q1
        (fun s1 b s3 => Exist2 (fun a s2 => R1 s1 a s2 /\ R2 a s2 b s3))
    :=
        fun s1 bind_pre =>
            match m s1 bind_pre with
            | make_pair a s2 sat1 =>
                _
            end.*)



End hoare_state2.
End Hoare_state2.




(* Trace model
   ===========
*)

Module Trace_IO.
Section trace.
    Variable Event: Type.

    Definition Trace: Type := list Event.


    Definition Spec (A: Type): Type :=
        Trace -> A -> Trace -> Prop.


    Inductive Pre {A: Type} (S: Spec A) (t1: Trace): Prop :=
        | make_pre: forall a t2, S t1 a t2 -> Pre S t1.

    Arguments make_pre {_ _ _ _ _} _.


    Inductive Pair {A: Type} (P: A -> Trace -> Prop): Prop :=
        make_pair a t2: P a t2 -> Pair P.

    Arguments make_pair {_ _}. (* a and t2 are not implicit. *)


    Inductive Post {A: Type} (P: A -> Trace -> Prop): Prop :=
        make_post a t2: P a t2 -> Post P.

    Arguments make_post {_ _ _ _}.



    Definition Pure {A: Type} (a: A): Spec A :=
        fun t1 x t2 => a = x /\ t2 = nil.


    Definition Bind
        {A B: Type}
        (T1: Spec A) (F: A -> Spec B): Spec B
    :=
        fun t1 b t3 =>
            Post (T1 t1)
            /\
            forall a t2, T1 t1 a t2 -> F a (t2 ++ t1) b t3.



    Definition Hoare {A: Type} (S: Spec A): Type :=
        forall t1,
            Pre S t1
            ->
            Pair (fun a t2 => S t1 a t2).



    Definition pure {A: Type} (x: A): Hoare (Pure x) :=
        fun t1 p =>
        make_pair x nil (conj eq_refl eq_refl: Pure x t1 x nil).

(*
    Definition bind
        {A B: Type} {S1: Spec A} {F: A -> Spec B}
    : Hoare S1
      -> (forall x, Hoare (F x))
      -> Hoare (Bind S1 F)
    :=
        fun c f t1 bnd_pre =>
        let pre1: Pre S1 t1 :=
            match bnd_pre with
            | make_pre (conj (make_post sat) nxt) =>
                make_pre sat
            end
        in
        match c t1 pre1 with
            make_pair a t2 sat1 =>
                let pre2: Pre (F a) (t2 ++ t1):=
                    match bnd_pre with
                    | make_pre (conj _ nxt) =>
                        make_pre (nxt _ _ sat1)
                    end
                in
                match f a (t2 ++ t1) pre2 with
                    make_pair b t3 sat2 =>
                        make_pair
                            b
                            t3
                            (conj
                                (make_post sat1)
                                (fun a t2 sat1 => _)
                            : Bind S1 F t1 b t3)
                end
        end.*)
End trace.
End Trace_IO.
