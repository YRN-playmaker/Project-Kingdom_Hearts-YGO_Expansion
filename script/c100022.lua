-- 觉醒之力
function c100022.initial_effect(c)
	-- ①：发动（融合召唤）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,100022+EFFECT_COUNT_CODE_OATH) -- 卡名1回合1张
	e1:SetTarget(c100022.target)
	e1:SetOperation(c100022.activate)
	c:RegisterEffect(e1)
	
	-- ②：墓地发动（特招任意数量）
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- 除非文本写了“对方回合也能发动”，否则速攻魔法墓地效果通常是 Ignition (1速)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,100023) -- 建议给个独立的ID限制，避免冲突
	e2:SetCondition(c100022.grave_condition)
	e2:SetCost(c100022.grave_cost)
	e2:SetTarget(c100022.grave_target)
	e2:SetOperation(c100022.grave_activate)
	c:RegisterEffect(e2)
end

-- 字段定义：键刃使
local SET_KEYBLADE = 0x208 

----------------------------------------------------------------
-- ① 效果：融合召唤 (Field + Grave 除外)
----------------------------------------------------------------
function c100022.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
function c100022.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c100022.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_KEYBLADE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c100022.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end

function c100022.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(c100022.filter0,nil)
		local mg2=Duel.GetMatchingGroup(c100022.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(c100022.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c100022.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end

function c100022.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c100022.filter1,nil,e)
	local mg2=Duel.GetMatchingGroup(c100022.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	local sg1=Duel.GetMatchingGroup(c100022.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c100022.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

----------------------------------------------------------------
-- ② 效果：墓地特招 + 自肃
----------------------------------------------------------------
function c100022.grave_condition(e,tp,eg,ep,ev,re,r,rp)
	-- 我方场上没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

function c100022.grave_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function c100022.grave_filter(c,e,tp)
	return c:IsSetCard(SET_KEYBLADE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function c100022.grave_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100022.grave_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function c100022.grave_activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end -- 防青眼精灵龙
	
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c100022.grave_filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 核心优化：使用 SelectSubGroup + aux.dncheck 实现“同名卡最多1张”且“任意数量”
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	
	if sg then
		local c=e:GetHandler()
		-- 一次性召唤
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE) > 0 then
			-- 注册自肃效果
			-- 1. 给召唤的怪兽打上Flag
			local tc=sg:GetFirst()
			for tc in aux.Next(sg) do
				tc:RegisterFlagEffect(100022,RESET_EVENT+RESETS_STANDARD,0,1)
			end
			
			-- 2. 注册全局限制：只要Flag怪兽在场，不能特招非融合
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetCondition(c100022.splimit_con)
			e1:SetTarget(c100022.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END,20) -- 给予一个很长的重置时间，实际上靠Condition控制
			-- 更好的方式是不设Reset，或者绑定对象，但全局Effect很难绑定Group。
			-- 这种写法依靠Condition判断，当没有Flag怪兽时，Condition不成立，效果不适用。
			Duel.RegisterEffect(e1,tp)
		end
	end
end

-- 检查场上是否有被这张卡召唤的怪兽
function c100022.splimit_con(e)
	return Duel.IsExistingMatchingCard(c100022.flag_filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function c100022.flag_filter(c)
	return c:GetFlagEffect(100022)>0 and c:IsFaceup()
end

-- 自肃逻辑：非融合怪兽 && 从额外卡组
function c100022.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
