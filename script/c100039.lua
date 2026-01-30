-- c100039.lua
function c100039.initial_effect(c)
	-- Effect ①：除外自身，特殊召唤2个token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100039,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,100039)
	e1:SetCost(c100039.spcost)
	e1:SetTarget(c100039.sptg)
	e1:SetOperation(c100039.spop)
	c:RegisterEffect(e1)

	-- Effect ②：连接召唤，素材必须包含自身
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100039,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100139)
	e2:SetCondition(c100039.lkcon)
	e2:SetCost(c100039.lkcost)
	e2:SetTarget(c100039.lktg)
	e2:SetOperation(c100039.lkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e4)
end

-- Effect ①：COST → 只支付LP，不再在cost中除外自身
function c100039.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end

-- Effect ①：目标检查
function c100039.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,100001,0,TYPES_TOKEN_MONSTER,500,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_DEFENSE,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

-- Effect ①：处理，除外自身直到回合结束，并召唤2 token
function c100039.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	-- 除外自身直到结束阶段
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c100039.retop)
		Duel.RegisterEffect(e1,tp)

		-- 特殊召唤2个token
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 then
			for i=1,2 do
				local token=Duel.CreateToken(tp,100001)
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_DEFENSE)
			end
			Duel.SpecialSummonComplete()
		end
	end
end

-- Effect ①：结束阶段返回自身
function c100039.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end

-- Effect ②：发动条件 → 对方主要阶段
function c100039.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end

-- Effect ②：Cost → 从卡组顶3张里侧除外
function c100039.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDecktopGroup(tp,3):FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3 end
	local g=Duel.GetDecktopGroup(tp,3)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end

-- Effect ②：目标 → 不提前判断连接合法性
function c100039.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Effect ②：连接召唤，素材必须包含自身
function c100039.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

	-- 查找额外卡组中，能够用“包含这张卡”为素材连接召唤的怪兽
	local g = Duel.GetMatchingGroup(function(tc)
		return tc:IsType(TYPE_LINK) and tc:IsLinkSummonable(nil, c)
	end, tp, LOCATION_EXTRA, 0, nil)

	if #g == 0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc = g:Select(tp,1,1,nil):GetFirst()
	if not sc then return end

	-- 关键点：必须使用c本身为连接素材
	Duel.LinkSummon(tp, sc, nil, c)
end

