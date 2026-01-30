function c100032.initial_effect(c)
	c:EnableCounterPermit(0x3d1)

	--① 放置累计量表指示物
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c100032.ctop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--② 取除指示物发动效果（抽卡或加入指定卡）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100032,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,100032)
	e3:SetCondition(c100032.drcon)
	e3:SetCost(c100032.drcost)
	e3:SetTarget(c100032.drtg)
	e3:SetOperation(c100032.drop)
	c:RegisterEffect(e3)

	--③ 仪式解放时破坏盖放卡
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCondition(c100032.descon)
	e4:SetOperation(c100032.desop_cont)
	c:RegisterEffect(e4)
end

function c100032.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not eg:IsContains(c) and c:IsFaceup() and c:IsOnField() then
		if c:GetCounter(0x3d1)<3 then
			c:AddCounter(0x3d1,1)
		end
	end
end

--②效果部分：条件/代价
function c100032.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3d1)>=3
end
function c100032.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x3d1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x3d1,3,REASON_COST)
end
function c100032.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		or Duel.IsExistingMatchingCard(c100032.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c100032.thfilter(c)
	return c:IsCode(100066) and c:IsAbleToHand()
end
function c100032.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local opt=Duel.SelectOption(tp,aux.Stringid(100032,1),aux.Stringid(100032,2))
	if opt==0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c100032.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end


--③ 仪式解放触发 → 破坏盖放卡
function c100032.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),REASON_RITUAL)~=0
end
function c100032.desop_cont(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,100032)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
