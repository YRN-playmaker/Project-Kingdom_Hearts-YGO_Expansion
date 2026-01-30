-- 键刃使 索拉 Wisdom Form
function c100019.initial_effect(c)
	-- 连接召唤
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x208),2,2)

	-- ①：解放变身（特殊召唤规则）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100019,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,100019)
	e1:SetCondition(c100019.spcon)
	e1:SetOperation(c100019.spop)
	c:RegisterEffect(e1)

	-- ②：三色康 + 回收魔法
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100019,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100019+100)
	e2:SetCondition(c100019.negcon)
	e2:SetCost(c100019.negcost)
	e2:SetTarget(c100019.negtg)
	e2:SetOperation(c100019.negop)
	c:RegisterEffect(e2)
end

----------------------------------------------------------------
-- ① 特殊召唤逻辑
----------------------------------------------------------------
function c100019.spfilter(c,tp,sc)
	-- 必须检查 GetLocationCountFromEx，确保解放后有格子给 sc (Wisdom Form) 用
	return c:IsSetCard(0x208) and c:IsLevel(8) and c:IsReleasable()
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end

function c100019.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- CheckReleaseGroup 只是检查能否解放，这里我们要用自定义 filter 配合
	return Duel.IsExistingMatchingCard(c100019.spfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end

function c100019.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 这里不需要用 SelectReleaseGroup，直接用 SelectMatchingCard 配合 spfilter 更稳
	local g=Duel.SelectMatchingCard(tp,c100019.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	Duel.Release(g,REASON_COST)
end

----------------------------------------------------------------
-- ② 无效逻辑
----------------------------------------------------------------
function c100019.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.IsChainNegatable(ev)
end

-- 手卡Cost过滤器：必须和 re 的类型一致
function c100019.cfilter(c,type)
	return c:IsType(type) and c:IsDiscardable()
end

function c100019.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 【修正】使用 IsActiveType 判断发动类型，而非 GetHandler():GetType()
	-- 这样可以正确处理灵摆怪兽在刻度发动魔法效果的情况
	local type=0
	if re:IsActiveType(TYPE_MONSTER) then type=TYPE_MONSTER
	elseif re:IsActiveType(TYPE_SPELL) then type=TYPE_SPELL
	elseif re:IsActiveType(TYPE_TRAP) then type=TYPE_TRAP end

	if chk==0 then return type~=0 and Duel.IsExistingMatchingCard(c100019.cfilter,tp,LOCATION_HAND,0,1,nil,type) end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c100019.cfilter,tp,LOCATION_HAND,0,1,1,nil,type)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

function c100019.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- Destructable 检查通常在 Operation 做，Target 阶段只要对象在就可以
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 回收魔法是可选且不取对象的，可以SetInfo但不强制 Check
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,PLAYER_ALL,LOCATION_GRAVE)
end

function c100019.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function c100019.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 【修正】判定逻辑：无效 -> 破坏 -> (如果破坏成功) -> 回收
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 墓地回收检测：加入 NecroValleyFilter 防王谷
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c100019.thfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(100019,2)) then
			Duel.BreakEffect() -- 破坏和回收视为非同时处理 (那之后)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end