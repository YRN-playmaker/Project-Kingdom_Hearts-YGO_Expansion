-- 超量怪兽 (c100048)
function c100048.initial_effect(c)
	-- 4星怪兽x2以上 (修正注释x3 -> x2)
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()

	-- 属性当作「暗」
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e0)

	-- ①：取对象抗性（无效并破坏）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100048,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c100048.negcon)
	e1:SetCost(c100048.cost) -- 通用Cost
	e1:SetOperation(c100048.negop)
	c:RegisterEffect(e1)

	-- ②：被攻击时（无效攻击+加攻守）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100048,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE) -- 修正Category
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCost(c100048.cost) -- 通用Cost
	e2:SetOperation(c100048.atkop)
	c:RegisterEffect(e2)

	-- ③：无素材不能攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetCondition(c100048.no_mat_con)
	c:RegisterEffect(e3)

	-- ③：无素材回合结束回额外
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100048,2))
	e4:SetCategory(CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c100048.no_mat_con)
	e4:SetTarget(c100048.rettg)
	e4:SetOperation(c100048.retop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 公用 Cost：去除1个素材
--------------------------------------------------------------------------------
function c100048.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

--------------------------------------------------------------------------------
-- 效果①：对象康
--------------------------------------------------------------------------------
function c100048.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsChainNegatable(ev) then return false end
	-- 关键修正：必须判断是否是“取对象”的效果
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	
	-- 获取被取对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象中是否有“自己场上的怪兽”
	return g and g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) 
		   and g:IsExists(Card.IsControler,1,nil,tp)
end

function c100048.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- 效果②：无效攻击 + 加攻守
--------------------------------------------------------------------------------
function c100048.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 先无效攻击
	if Duel.NegateAttack() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 再加攻守
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end

--------------------------------------------------------------------------------
-- 效果③：无素材判定与回卡组
--------------------------------------------------------------------------------
function c100048.no_mat_con(e)
	return e:GetHandler():GetOverlayCount()==0
end

function c100048.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end -- 强制效果通常不需要具体check IsAbleToExtra，除非是严格模式
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end

function c100048.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end