--傻逼[]卡组给老子滚！
--虚空之宣告
function c1000333.initial_effect(c)
	--发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c1000333.condition)
	e1:SetTarget(c1000333.target)
	e1:SetOperation(c1000333.activate)
	c:RegisterEffect(e1)
end

function c1000333.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp --对方发动效果时
end

function c1000333.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

function c1000333.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	local sets=tc:GetSetCard()
	if sets==0 then return end --没字段就不处理

	local g1=Duel.GetMatchingGroup(c1000333.rmfilter,tp,LOCATION_DECK,0,nil,sets)
	local g2=Duel.GetMatchingGroup(c1000333.rmfilter,tp,0,LOCATION_DECK,nil,sets)
	local g=Group.CreateGroup()
	g:Merge(g1)
	g:Merge(g2)

	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function c1000333.rmfilter(c,sets)
	return c:IsSetCard(sets) and c:IsAbleToRemove()
end
