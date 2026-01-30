-- 键刃使 阿克塞尔
function c100069.initial_effect(c)
	-- Pendulum Attribute
	aux.EnablePendulumAttribute(c)

	-- Pendulum Effect 1: Special Summon from Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100069,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,100069)
	e1:SetCondition(c100069.spcon)
	e1:SetTarget(c100069.sptg)
	e1:SetOperation(c100069.spop)
	c:RegisterEffect(e1)

	-- Pendulum Effect 2: Negate specific effects by banishing self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100069,2))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,100069+100)
	e2:SetCondition(c100069.negcon)
	e2:SetCost(c100069.negcost)
	e2:SetTarget(c100069.negtg)
	e2:SetOperation(c100069.negop)
	c:RegisterEffect(e2)

	-- Monster Effect: Add 1 "键刃使" monster from Graveyard to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100069,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c100069.thtg)
	e3:SetOperation(c100069.thop)
	c:RegisterEffect(e3)
end

-- Pendulum Effect 1 Condition
function c100069.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end

-- Pendulum Effect 1 Target
function c100069.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Pendulum Effect 1 Operation
function c100069.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Pendulum Effect 2 Condition
function c100069.negcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		and (re:IsHasCategory(CATEGORY_TOHAND+CATEGORY_SEARCH) or re:IsHasCategory(CATEGORY_SPECIAL_SUMMON))
end

-- Pendulum Effect 2 Cost
function c100069.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- Pendulum Effect 2 Target
function c100069.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsChainDisablable(ev) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

-- Pendulum Effect 2 Operation
function c100069.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

-- Monster Effect Target
function c100069.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100069.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

-- Monster Effect Filter
function c100069.thfilter(c)
	return c:IsSetCard(0x208) and c:IsLevelAbove(4) and c:IsAbleToHand()
end

-- Monster Effect Operation
function c100069.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100069.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


