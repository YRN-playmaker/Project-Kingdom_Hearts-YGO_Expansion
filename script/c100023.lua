-- 键刃使 凯莉 Final Form
function c100023.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,100009,aux.FilterBoolFunction(Card.IsSetCard,0x208),1,true,true)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-- Quick Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100023,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,100023)
	e1:SetCost(c100023.fusioncost)
	e1:SetTarget(c100023.fusiontg)
	e1:SetOperation(c100023.fusionop)
	c:RegisterEffect(e1)
end

function c100023.fusioncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- 只检查来源和是否能回卡组
function c100023.matfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_MZONE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
		and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

-- 检查融合怪兽是否可特召，且不是自己
function c100023.spfilter(c,e,tp,mg,chkf)
	return c:IsType(TYPE_FUSION) and not c:IsCode(100023)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end

function c100023.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetMatchingGroup(c100023.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
		local res=Duel.IsExistingMatchingCard(c100023.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c100023.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c100023.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(c100023.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	local sg1=Duel.GetMatchingGroup(c100023.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c100023.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	local sg=sg1:Clone()
	if sg2 then sg:Merge(sg2) end
	if sg:GetCount()==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if not sc then return end

	local use_chain_material = false
	if sg2 and sg2:IsContains(sc) and (not sg1:IsContains(sc) or Duel.SelectYesNo(tp,aux.Stringid(100023,1))) then
		use_chain_material = true
	end

	if not use_chain_material then
		local mat1=Duel.SelectFusionMaterial(tp,sc,mg1,nil,chkf)
		sc:SetMaterial(mat1)
		Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	else
		local fop=ce:GetOperation()
		fop(ce,e,tp,sc)
	end
	sc:CompleteProcedure()
end
