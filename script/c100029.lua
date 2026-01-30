--高飞
function c100029.initial_effect(c)
	--灵摆设置
	aux.EnablePendulumAttribute(c)

	--P效果：攻击无效并特召
	--①：对方的怪兽的攻击宣言时才能发动。那次攻击无效。那之后，灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100029,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,100029)
	e1:SetCondition(c100029.negcon)
	e1:SetTarget(c100029.negtg)
	e1:SetOperation(c100029.negop)
	c:RegisterEffect(e1)

	--怪兽效果：攻击诱导/保护
	--②：只要这张卡在怪兽区域存在，对方不能把其他的「键刃使」以及「DS」怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE) -- 作用于对方场上的怪兽
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(c100029.atlimit)
	c:RegisterEffect(e2)
end

-- P效果 Condition: 对方攻击宣言
function c100029.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end

-- P效果 Target: 检查是否有格子且自身能否特召
function c100029.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- P效果 Operation: 无效攻击 -> 特召
function c100029.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 只有在P区且攻击无效成功时才特召
	if c:IsRelateToEffect(e) and Duel.NegateAttack() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- 怪兽效果 Value: 筛选由于此效果不能成为目标的卡
-- 返回 true 的卡片不能被对方选择为攻击对象
function c100029.atlimit(e,c)
	return c:IsFaceup() 
		and (c:IsSetCard(0x208) or c:IsSetCard(0x209)) -- 键刃使 或 DS
		and c~=e:GetHandler() -- 排除自身
end