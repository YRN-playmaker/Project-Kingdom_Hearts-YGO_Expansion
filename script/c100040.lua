--DS 黄昏镇XXX
--卡片密码 100040
function c100040.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--效果①：手卡送墓 -> 回收除外 -> 墓地除外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100040,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,100040)
	e2:SetCost(c100040.cost)
	e2:SetTarget(c100040.target)
	e2:SetOperation(c100040.operation)
	c:RegisterEffect(e2)
end

--Cost：手卡怪兽送墓
function c100040.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function c100040.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100040.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c100040.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

--Filter：除外区的怪兽回收
function c100040.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

--Filter：墓地怪兽除外
function c100040.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function c100040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c100040.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100040.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c100040.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end

function c100040.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	
	--先处理：回收除外
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		
		--那之后：墓地除外 (必发)
		--检查墓地是否有怪兽 (Cost送去了一张，所以正常情况下一定有，但防止连锁D.D.乌鸦等情况需判空)
		local g=Duel.GetMatchingGroup(c100040.rmfilter,tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end