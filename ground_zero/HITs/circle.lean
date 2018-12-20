import ground_zero.HITs.suspension ground_zero.theorems.ua
open ground_zero.structures (hset)

namespace ground_zero
namespace HITs

universes u v

notation [parsing_only] `S⁻¹` := empty
notation [parsing_only] `S⁰` := bool

local infix ` = ` := eq

theorem up_dim : ∑S⁻¹ ≃ S⁰ :=
let f : ∑S⁻¹ → S⁰ :=
suspension.rec ff tt (λ e, by induction e) in
let g : S⁰ → ∑S⁻¹ :=
λ b, match b with
  ff := suspension.north
| tt := suspension.south
end in begin
  existsi f, split; existsi g,
  { intro x, simp,
    refine @suspension.ind _
      (λ x, g (f x) = x)
      (by reflexivity)
      (by reflexivity)
      _ x,
    intro u, induction u },
  { intro x, simp, induction x,
    repeat { trivial } }
end

def circle := ∑S⁰
notation `S¹` := circle

namespace circle
  -- https://github.com/leanprover/lean2/blob/master/hott/homotopy/circle.hlean
  def base₁ : S¹ := suspension.north
  def base₂ : S¹ := suspension.south

  def seg₁ : base₁ = base₂ := suspension.merid ff
  def seg₂ : base₁ = base₂ := suspension.merid tt

  def ind₂ {β : S¹ → Type u} (b₁ : β base₁) (b₂ : β base₂)
    (ℓ₁ : b₁ =[seg₁] b₂)
    (ℓ₂ : b₁ =[seg₂] b₂) : Π (x : S¹), β x :=
  suspension.ind b₁ b₂ (begin
    intro x, induction x,
    exact ℓ₁, exact ℓ₂
  end)

  def base : S¹ := base₁
  def loop : base = base := seg₂ ⬝ seg₁⁻¹

  def rec {β : Type u} (b : β) (ℓ : b = b) : S¹ → β :=
  suspension.rec b b (λ _, ℓ)

  theorem recβrule₁ {β : Type u} (b : β) (ℓ : b = b) :
    rec b ℓ base = b := eq.rfl

  def ind {β : S¹ → Type u} (b : β base)
    (ℓ : b =[loop] b) : Π (x : S¹), β x :=
  ind₂ b (equiv.subst seg₁ b) eq.rfl
    (begin
      have p := equiv.subst_comp seg₂ seg₁⁻¹ b,
      have q := (λ p, equiv.subst p (equiv.subst seg₂ b)) #
                (eq.inv_comp seg₁),
      transitivity, exact q⁻¹, transitivity,
      exact equiv.subst_comp seg₁⁻¹ seg₁ (equiv.subst seg₂ b),
      symmetry, exact equiv.subst seg₁ # (ℓ⁻¹ ⬝ p)
    end)

  instance pointed_circle : eq.dotted S¹ := ⟨base⟩

  theorem natural_equivalence {α : Sort u} :
    (S¹ → α) ≃ (Σ' (x : α), x = x) := begin
    let f : (S¹ → α) → (Σ' (x : α), x = x) :=
    λ g, ⟨g base, g # loop⟩,
    let g : (Σ' (x : α), x = x) → (S¹ → α) :=
    λ p x, p.fst,
    existsi f, split; existsi g,
    repeat { admit }
  end

  namespace going
    def trivial : S¹ → S¹ :=
    rec base (eq.refl base)

    def nontrivial : S¹ → S¹ :=
    rec base loop
  end going

  def succ (l : Ω¹(S¹)) : Ω¹(S¹) := l ⬝ loop
  def pred (l : Ω¹(S¹)) : Ω¹(S¹) := l ⬝ loop⁻¹

  def zero := eq.refl base
  def one := succ zero
  def two := succ one
  def three := succ two
  def fourth := succ three

  inductive int
  | pos : ℕ → int
  | zero
  | neg : ℕ → int
  /-
    pos 1 is    2
    pos 0 is    1
    zero is     0
    neg 0 is   −1
    neg 1 is   −2
  -/

  instance : has_repr int :=
  ⟨λ x, match x with
  | (int.pos n) := to_string (n + 1)
  | int.zero := "0"
  | (int.neg n) := "−" ++ to_string (n + 1)
  end⟩

  def int.succ : int → int
  | (int.pos n) := int.pos (n + 1)
  | int.zero := int.pos 0
  | (int.neg 0) := int.zero
  | (int.neg (n + 1)) := int.neg n

  def int.pred : int → int
  | (int.pos 0) := int.zero
  | (int.pos (n + 1)) := int.pos n
  | int.zero := int.neg 0
  | (int.neg n) := int.neg (n + 1)

  theorem int.equiv : int ≃ int := begin
    existsi int.succ, split; existsi int.pred,
    { intro n, induction n,
      repeat { trivial },
      { induction n with n ih,
        repeat { trivial } } },
    { intro n, induction n,
      { induction n with n ih,
        repeat { trivial } },
      repeat { trivial } }
  end

  def code : S¹ → Type :=
  rec int (ua int.equiv)

  def pos : ℕ → Ω¹(S¹)
  | 0 := loop
  | (n+1) := pos n ⬝ loop

  def neg : ℕ → Ω¹(S¹)
  | 0 := loop
  | (n+1) := pos n ⬝ loop⁻¹

  def encode (x : S¹) (p : base = x) : code x :=
  equiv.transport code p int.zero

  def power : int → Ω¹(S¹)
  | (int.pos n) := pos n
  | int.zero := eq.refl base
  | (int.neg n) := neg n

  example : power (int.pos 2) = loop ⬝ loop ⬝ loop :=
  by reflexivity

  def winding (x : base = base) : int :=
  let n : code base := equiv.transportconst (code # x) int.zero in n
end circle

namespace ncircle
  def S : ℕ → Sort _
  | 0 := S⁰
  | (n + 1) := ∑(S n)
end ncircle

namespace sphere
  notation `S²` := ncircle.S 2

  abbreviation base₁ : S² := suspension.north
  abbreviation base₂ : S² := suspension.south

  def loop : base₁ = base₂ := suspension.merid circle.base

  def surf_trans :=
  (λ p, suspension.merid p ⬝ loop⁻¹) # circle.loop

  abbreviation base : S² := suspension.north
  def surf : eq.refl base = eq.refl base :=
  (eq.comp_inv loop)⁻¹ ⬝ surf_trans ⬝ (eq.comp_inv loop)

  def rec {β : Type u} (b : β) (s : eq.refl b = eq.refl b) : S² → β :=
  suspension.rec b b (circle.rec (eq.refl b) s)

  def ind {π : S² → Type u} (b : π base)
    (s : eq.refl b =[λ p, b =[π, p] b, surf] eq.refl b) : Π (x : S²), π x := begin
    refine suspension.ind b (equiv.subst loop b) _,
    intro x, refine circle.ind _ _ x,

    reflexivity,
    admit
  end
end sphere

def torus := S¹ × S¹
notation `T²` := torus

namespace torus
  def b : T² := ⟨circle.base, circle.base⟩

  def inj₁ : S¹ → T² := product.intro circle.base
  def inj₂ : S¹ → T² := function.swap product.intro circle.base

  abbreviation prod {α : Type u} {β : Type v} {a b : α} {c d : β}
    (p : a = b) (q : c = d) :
    ⟨a, c⟩ = ⟨b, d⟩ :> α × β :=
  product.construction a b c d p q

  -- poloidal and toroidal directions
  def p : b = b :> T² := prod (eq.refl circle.base) circle.loop
  def q : b = b :> T² := prod circle.loop (eq.refl circle.base)

  def Φ {π : Type u} {x x' y y' : π}
    (α : x = x' :> π) (β : y = y' :> π) :
    prod (eq.refl x) β ⬝ prod α (eq.refl y') =
    prod α (eq.refl y) ⬝ prod (eq.refl x') β :> _ :=
  begin induction α, induction β, trivial end

  def t : p ⬝ q = q ⬝ p :> b = b :> T² :=
  Φ circle.loop circle.loop

  def ind {π : T² → Type u} (b' : π b)
    (p' : b' =[p] b') (q' : b' =[q] b')
    (t' : p' ⬝ q' =[(λ r, equiv.subst r b' = b'), t] q' ⬝ p') :
    Π (x : T²), π x := begin
    intro x, cases x with poloidal toroidal,
    refine circle.ind _ _ poloidal,
    { refine circle.ind _ _ toroidal,
      exact b', admit },
    { admit }
  end
end torus

end HITs
end ground_zero