-- 通常魔法：指令动作-键刃变形
function c100025.initial_effect(c)
	-- ①效果：场上送墓 -> 卡组检索
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100025,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 注意：两个效果共享同一个 CountLimit ID，实现“二选一”
	e1:SetCountLimit(1,100025)
	e1:SetCost(c100025.cost)
	e1:SetTarget(c100025.target)
	e1:SetOperation(c100025.operation)
	c:RegisterEffect(e1)

	-- ②效果：墓地除外 -> 墓地回收
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100025,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 注意：与 e1 使用相同的 ID
	e2:SetCountLimit(1,100025)
	e2:SetCost(aux.bfgcost) -- 标准的“把墓地这张卡除外”Cost
	e2:SetTarget(c100025.grave_target)
	e2:SetOperation(c100025.grave_operation)
	c:RegisterEffect(e2)
end

-- ==================================================
-- ①效果部分
-- ==================================================
-- Cost: 把自己场上1张装备魔法卡送去墓地
function c100025.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_SZONE,0,1,nil,TYPE_EQUIP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_SZONE,0,1,1,nil,TYPE_EQUIP)
	Duel.SendtoGrave(g,REASON_COST)
end

-- Target: 确认卡组有装备魔法
function c100025.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function c100025.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100025.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Operation: 检索上手
function c100025.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100025.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ==================================================
-- ②效果部分
-- ==================================================
-- Target: 选择墓地怪兽
function c100025.grave_filter(c)
	return c:IsSetCard(0x208) and c:IsAbleToHand()
end
function c100025.grave_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c100025.grave_filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100025.grave_filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c100025.grave_filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

-- Operation: 回收上手
function c100025.grave_operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end