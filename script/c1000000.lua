-- 真王夜空
function c1000000.initial_effect(c)
	c:EnableReviveLimit()
	
	-- 特殊召唤规则：场上无怪 + 除外区索拉给对方
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e0:SetRange(LOCATION_HAND)
	e0:SetTargetRange(POS_FACEUP,0) -- 召唤到自己场上
	e0:SetCondition(c1000000.spcon)
	e0:SetOperation(c1000000.spop)
	c:RegisterEffect(e0)

	-- ①：「真王夜空」在场上只能有1只表侧表示存在
	c:SetUniqueOnField(1,0,1000000)

	-- ②：不受怪兽的效果影响 + 不能解放
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCode(EFFECT_IMMUNE_EFFECT)
	e2a:SetValue(c1000000.efilter)
	c:RegisterEffect(e2a)
	
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCode(EFFECT_CANNOT_RELEASE) -- 核心抗性：不能被解放
	e2b:SetValue(1)
	c:RegisterEffect(e2b)

	-- ③：压制召唤（对方1回合只能1次）- 永续效果
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCode(EFFECT_CANNOT_SUMMON)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a:SetTargetRange(0,1) -- 针对对方
	e3a:SetTarget(c1000000.sumlimit)
	c:RegisterEffect(e3a)
	
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e3b)
	
	-- ③：攻击力上升 - 强制诱发效果 (Trigger-F)
	-- 分别注册召唤和特殊召唤事件
	local e3c=Effect.CreateEffect(c)
	e3c:SetDescription(aux.Stringid(1000000,0))
	e3c:SetCategory(CATEGORY_ATKCHANGE)
	e3c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3c:SetCode(EVENT_SUMMON_SUCCESS)
	e3c:SetRange(LOCATION_MZONE)
	e3c:SetCondition(c1000000.atkcon)
	e3c:SetOperation(c1000000.atkop)
	c:RegisterEffect(e3c)
	
	local e3d=e3c:Clone()
	e3d:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3d)

	-- ④：无效装备魔法并装备 - 二速即时诱发
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1000000,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,1000000) -- 修正ID为1000000
	e4:SetCondition(c1000000.negcon)
	e4:SetTarget(c1000000.negtg)
	e4:SetOperation(c1000000.negop)
	c:RegisterEffect(e4)
end

-- 关联卡片ID (键刃使 索拉)
local CARD_SORA = 100000 

----------------------------------------------------------------
-- 特殊召唤逻辑
----------------------------------------------------------------
function c1000000.spfilter(c)
	-- 必须是索拉 且 能加入手卡
	return c:IsCode(CARD_SORA) and c:IsAbleToHandAsCost()
end

function c1000000.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 场上没有怪兽 + 除外区有索拉 + 有格子
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c1000000.spfilter,tp,LOCATION_REMOVED,0,1,nil)
end

function c1000000.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,c1000000.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 强制加入 1-tp (对方) 手卡
		Duel.SendtoHand(g, 1-tp, REASON_COST)
		Duel.ConfirmCards(1-tp,g)
	end
end

----------------------------------------------------------------
-- 抗性逻辑
----------------------------------------------------------------
function c1000000.efilter(e,te)
	-- 不受怪兽效果影响 (Owner不同)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end

----------------------------------------------------------------
-- ③ 召唤限制逻辑 (永续)
----------------------------------------------------------------
function c1000000.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	-- 检查对方已经进行过的召唤+特召次数
	return Duel.GetActivityCount(1-e:GetHandlerPlayer(),ACTIVITY_SUMMON) 
		 + Duel.GetActivityCount(1-e:GetHandlerPlayer(),ACTIVITY_SPSUMMON) >= 1
end

----------------------------------------------------------------
-- ③ 攻击力上升逻辑 (诱发)
----------------------------------------------------------------
function c1000000.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 触发条件：对方(1-tp)进行了召唤
	return ep~=tp
end

function c1000000.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- eg 是当前召唤成功的怪兽集合
	local tc=eg:GetFirst()
	-- 如果一次出多只，取攻击力最高的
	if #eg>1 then
		tc=eg:GetMaxGroup(Card.GetBaseAttack):GetFirst()
	end
	
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		
		-- 增加攻击力直到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		
		-- 视觉提示
		Duel.Hint(HINT_CARD,0,1000000)
	end
end

----------------------------------------------------------------
-- ④ 无效装备魔法
----------------------------------------------------------------
function c1000000.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and re:GetHandler():IsType(TYPE_EQUIP) and Duel.IsChainNegatable(ev)
end

function c1000000.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,eg,1,0,0)
end

function c1000000.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	
	-- 无效并破坏
	if Duel.NegateActivation(ev) and Duel.Destroy(rc,REASON_EFFECT)~=0 then
		-- 确保破坏后在墓地，且夜空在场
		if rc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 装备给夜空
			Duel.Equip(tp,rc,c)
			
			-- 赋予装备卡效果：攻+1000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1)
			
			-- 装备对象限制（防止掉落）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(c1000000.eqlimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e2)
		end
	end
end

function c1000000.eqlimit(e,c)
	-- 必须装备给拥有者（真王夜空）
	return c==e:GetOwner()
end