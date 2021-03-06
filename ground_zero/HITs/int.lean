import ground_zero.types.heq

/-
  Integers ℤ as a quotient of ℕ × ℕ.
  * HoTT 6.10, remark 6.10.7
-/

abbreviation builtin.int := int

namespace ground_zero.HITs

def int.rel : ℕ × ℕ → ℕ × ℕ → Prop
| ⟨a, b⟩ ⟨c, d⟩ := a + d = b + c

def int := quot int.rel
local notation ℤ := int

namespace nat.product
  def add (x y : ℕ × ℕ) : ℕ × ℕ := begin
    cases x with a b, cases y with c d,
    split, apply a + c, apply b + d
  end
  instance : has_add (ℕ × ℕ) := ⟨add⟩

  def mul (x y : ℕ × ℕ) : ℕ × ℕ := begin
    cases x with a b, cases y with c d,
    split, apply a * c + b * d,
    apply a * d + b * c
  end
  instance : has_mul (ℕ × ℕ) := ⟨mul⟩

  lemma add_comm (x y : ℕ × ℕ) : x + y = y + x := begin
    cases x with a b, cases y with c d,
    simp [has_add.add], simp [add]
  end

  lemma mul_comm (x y : ℕ × ℕ) : x * y = y * x := begin
    cases x with a b, cases y with c d,
    simp [has_mul.mul], simp [mul], split,
    { rw [nat.mul_comm c a], rw [nat.mul_comm d b] },
    { rw [nat.mul_comm c b], rw [nat.mul_comm d a],
      rw [nat.add_comm (b * c) (a * d)] }
  end

  lemma rw.add (a b : ℕ × ℕ) : nat.product.add a b = a + b :=
  by trivial

  lemma rw.mul (a b : ℕ × ℕ) : nat.product.mul a b = a * b :=
  by trivial
end nat.product

namespace int
  universes u v

  def mk : ℕ × ℕ → ℤ := quot.mk rel
  def elem (a b : ℕ) : ℤ := quot.mk rel ⟨a, b⟩

  def pos (n : ℕ) := mk ⟨n, 0⟩
  instance : has_coe ℕ ℤ := ⟨pos⟩

  def neg (n : ℕ) := mk ⟨0, n⟩

  instance : has_zero int := ⟨mk ⟨0, 0⟩⟩
  instance : has_one int := ⟨mk ⟨1, 0⟩⟩

  def knife {a b c d : ℕ} (H : a + d = b + c :> ℕ) :
    mk ⟨a, b⟩ = mk ⟨c, d⟩ :> ℤ :=
  ground_zero.support.inclusion $ @quot.sound _ int.rel
    ⟨a, b⟩ ⟨c, d⟩ (ground_zero.support.truncation H)

  def ind {π : ℤ → Sort u}
    (mk₁ : Π (x : ℕ × ℕ), π (mk x))
    (knife₁ : Π {a b c d : ℕ} (H : a + d = b + c :> ℕ),
      mk₁ ⟨a, b⟩ =[knife H] mk₁ ⟨c, d⟩) (x : ℤ) : π x := begin
    refine quot.hrec_on x _ _,
    exact mk₁, intros x y p,
    cases x with a b, cases y with c d,
    refine ground_zero.types.eq.rec _
      (ground_zero.types.equiv.subst_from_pathover
        (knife₁ (ground_zero.support.inclusion p))),
    apply ground_zero.types.heq.eq_subst_heq
  end

  def injs {β : Sort u} (pos₁ : ℕ → β) (zero₁ : β) (neg₁ : ℕ → β) :
    ℕ × ℕ → β
  | ⟨0, 0⟩ := zero₁
  | ⟨n, 0⟩ := pos₁ n
  | ⟨0, n⟩ := neg₁ n
  | ⟨n + 1, m + 1⟩ := if n > m
    then injs ⟨n + 1, m⟩
    else injs ⟨n, m + 1⟩

  def simplify : ℕ × ℕ → ℕ × ℕ
  | ⟨0, 0⟩ := ⟨0, 0⟩
  | ⟨n + 1, 0⟩ := ⟨n + 1, 0⟩
  | ⟨0, n + 1⟩ := ⟨0, n + 1⟩
  | ⟨n + 1, m + 1⟩ := if n > m then ⟨n - m, 0⟩ else ⟨0, m - n⟩

  lemma ite.left {c : Prop} [decidable c] {α : Sort u} {x y : α}
    (h : not c) : ite c x y = y := begin
    unfold ite, tactic.unfreeze_local_instances,
    cases _inst_1 with u v, trivial, contradiction
  end

  lemma ite.right {c : Prop} [decidable c] {α : Sort u} {x y : α}
    (h : c) : ite c x y = x := begin
    unfold ite, tactic.unfreeze_local_instances,
    cases _inst_1 with u v, contradiction, trivial
  end

  /- theorem simplify_correct (x : ℕ × ℕ) : mk x = mk (simplify x) := begin
    apply quot.sound, cases x with u v,
    induction u with u ih₁,
    { induction v with v ih,
      repeat { simp [simplify, rel] } },
    { induction v with v ih₂,
      { simp [simplify, rel] },
      { simp [simplify],
        have H := nat.decidable_le (v + 1) u, induction H;
        unfold gt; unfold has_lt.lt; unfold nat.lt;
        unfold has_le.le at H,
        { rw [ite.left H], unfold rel,
          admit },
        { rw [ite.right H], unfold rel,
          admit } } }
  end

  def blade {π : ℤ → Sort u}
    (pos₁ : Π (n : ℕ), π (elem n 0))
    (zero₁ : π 0)
    (neg₁ : Π (n : ℕ), π (elem 0 n)) :
    Π x, π x := begin
    fapply ind,
    { intro x, cases x with u v, rw [simplify_correct],
      admit },
    admit
  end -/

  instance : has_neg int :=
  ⟨quot.lift
    (λ (x : ℕ × ℕ), mk ⟨x.pr₂, x.pr₁⟩)
    (begin
      intros x y H, simp,
      cases x with a b,
      cases y with c d,
      simp, apply quot.sound,
      simp [rel], simp [rel] at H,
      symmetry, assumption
    end)⟩

  lemma nat_rw (a b : ℕ) : nat.add a b = a + b :=
  by trivial

  def lift₂ (f : ℕ × ℕ → ℕ × ℕ → ℕ × ℕ)
    (h₁ : Π (a b x : ℕ × ℕ) (H : rel a b),
      mk (f x a) = mk (f x b))
    (h₂ : Π (a b : ℕ × ℕ),
      mk (f a b) = mk (f b a))
    (x y : int) : int :=
  quot.lift
    (λ x, quot.lift
          (λ y, mk (f x y))
          (begin intros a b H, simp, apply h₁, assumption end) y)
    (begin
      intros a b H, simp,
      induction y, simp,
      rw [h₂ a y], rw [h₂ b y], apply h₁,
      assumption, trivial
    end) x

  lemma add_saves_int {a b c d : ℕ} (H : a + d = b + c)
    (y : ℕ × ℕ) :
    mk (⟨a, b⟩ + y) = mk (⟨c, d⟩ + y) := begin
    cases y with u v,
    simp [has_add.add],
    apply quot.sound, simp [nat.product.add], simp [rel],
    rw [←nat.add_assoc], rw [H],
    rw [nat.add_assoc]
  end

  def eq_map {α : Sort u} {β : Sort v} {a b : α}
    (f : α → β) (p : a = b) : f a = f b :=
  begin induction p, reflexivity end

  def add : int → int → int := begin
    apply lift₂ nat.product.add,
    { intros x y u H,
      cases x with a b, cases y with c d,
      repeat { rw [nat.product.rw.add] },
      rw [nat.product.add_comm u ⟨a, b⟩],
      rw [nat.product.add_comm u ⟨c, d⟩],
      apply add_saves_int, assumption },
    { intros x y,
      apply eq_map mk,
      apply nat.product.add_comm }
  end

  instance : has_add int := ⟨add⟩
  instance : has_sub int := ⟨λ a b, a + (-b)⟩

  theorem inv_append (a : ℤ) : a + (-a) = 0 := begin
    induction a, cases a with u v,
    simp [has_neg.neg], apply quot.sound,
    simp [nat.product.add], simp [rel],
  end

  theorem send_to_right {a b c : ℤ} : (a + b = c) → (a = c - b) := begin
    intro h, induction a, induction b, induction c,
    cases a with x y, cases b with u v, cases c with p q,
    simp [has_sub.sub, has_neg.neg],
    rw [←h], simp [mk],
    simp [has_add.add] at *, apply quot.sound,
    simp [nat.product.add], simp [rel],
    repeat { trivial }
  end

  def mul : ℤ → ℤ → ℤ := begin
    apply lift₂ nat.product.mul,
    { intros x y z H,
      cases x with a b, cases y with c d,
      cases z with u v, simp [nat.product.mul],
      apply quot.sound, simp [rel],
      rw [←nat.add_assoc (u * a)],
      rw [←nat.add_assoc (u * b)],

      rw [←nat.left_distrib u a d],
      rw [←nat.left_distrib v b c],

      rw [←nat.left_distrib u b c],
      rw [←nat.left_distrib v a d],
      
      simp [rel] at H, rw [H] },
    { intros x y,
      apply eq_map mk,
      apply nat.product.mul_comm }
  end
  instance : has_mul int := ⟨mul⟩

  theorem k_equiv (a b k : ℕ) : mk ⟨a, b⟩ = mk ⟨a + k, b + k⟩ :=
  begin apply quot.sound, simp [rel] end
end int

end ground_zero.HITs