function c100034.initial_effect(c)
	-- 指示物设置
	c:EnableCounterPermit(0x3d1)
	c:SetCounterLimit(0x3d1,3)
	c:SetSPSummonOnce(100034)

	--① 无效发动并从手卡特召
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100034,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c100034.negcon)
	e1:SetTarget(c100034.negtg)
	e1:SetOperation(c100034.negop)
	c:RegisterEffect(e1)

	--② 送墓时放置指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c100034.ctop)
	c:RegisterEffect(e2)

	--③ 取除指示物：破坏或检索
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100034,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c100034.thcon)
	e3:SetCost(c100034.thcost)
	e3:SetTarget(c100034.thtg)
	e3:SetOperation(c100034.thop)
	c:RegisterEffect(e3)
end

--① 条件：对方发动包含从墓地特召的效果
function c100034.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.IsChainNegatable(ev)
		and re:IsActivated()
		and re:IsHasType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O+EFFECT_TYPE_IGNITION+EFFECT_TYPE_TRIGGER_O)
		and re:GetHandler():IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		and re:GetCategory()&CATEGORY_SPECIAL_SUMMON~=0
		and re:GetActivateLocation()==LOCATION_GRAVE
end
function c100034.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c100034.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

--② 每送墓1张卡放置1指示物（最多3）
function c100034.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsOnField() then return end
	local ct=#eg
	if ct > 0 then
		c:AddCounter(0x3d1, ct)
	end
end


--③ 条件：指示物>=3
function c100034.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3d1) >= 3
end
function c100034.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x3d1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x3d1,3,REASON_COST)
end
function c100034.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsDestructable()
end
function c100034.thfilter(c)
	return c:IsCode(100066) and c:IsAbleToHand()
end
function c100034.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c100034.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			or Duel.IsExistingMatchingCard(c100034.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function c100034.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local opt=Duel.SelectOption(tp,aux.Stringid(100034,2),aux.Stringid(100034,3))
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,c100034.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c100034.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
