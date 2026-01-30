--指令魔法-反射
function c100059.initial_effect(c)
 -- Effect 1: Destroy all opponent's attack position monsters when they declare an attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,100059+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c100059.destg)
	e1:SetOperation(c100059.desop)
	c:RegisterEffect(e1)
	
	-- Effect 2: Negate damage-dealing effects by banishing this card from the Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c100059.negcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c100059.negtg)
	e2:SetOperation(c100059.negop)
	c:RegisterEffect(e2)
end

function c100059.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsControler(1-tp) end
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function c100059.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

function c100059.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and re:IsHasCategory(CATEGORY_DAMAGE) and Duel.IsChainNegatable(ev)
end

function c100059.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function c100059.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
