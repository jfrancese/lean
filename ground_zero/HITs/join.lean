import ground_zero.HITs.suspension
open ground_zero.types.product (pr₁ pr₂)
open ground_zero.types.dep_path (pathover_of_eq)

hott theory

/-
  Join.
  * HoTT 6.8
-/

namespace ground_zero.HITs

universes u v w
def join (α : Type u) (β : Type v) :=
@pushout α β (α × β) pr₁ pr₂

namespace join
  variables {α : Type u} {β : Type v}

  def inl : α → join α β := pushout.inl
  def inr : β → join α β := pushout.inr

  def push (a : α) (b : β) : inl a = inr b :=
  pushout.glue (ground_zero.types.product.intro a b)

  def ind {π : join α β → Type w}
    (inl₁ : Π (x : α), π (inl x))
    (inr₁ : Π (x : β), π (inr x))
    (push₁ : Π (a : α) (b : β), inl₁ a =[push a b] inr₁ b) :
    Π (x : join α β), π x :=
  pushout.ind inl₁ inr₁
    (begin intro x, cases x with u v, exact push₁ u v end)

  def rec {π : Type w} (inlπ : α → π) (inrπ : β → π)
    (pushπ : Π a b, inlπ a = inrπ b) : join α β → π :=
  ind inlπ inrπ (λ a b, pathover_of_eq (push a b) (pushπ a b))

  def from_susp : ∑α → join bool α :=
  suspension.rec (inl ff) (inl tt)
    (λ x, push ff x ⬝ (push tt x)⁻¹)

  def to_susp : join bool α → ∑α :=
  rec (begin intro x, cases x,
        exact suspension.north,
        exact suspension.south
      end)
      (λ _, suspension.south)
      (begin
        intros x y, cases x,
        exact suspension.merid y,
        reflexivity
      end)

end join

end ground_zero.HITs