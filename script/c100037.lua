--X刃解放
function c100037.initial_effect(c)
	-- ① 仪式召唤：解放双方场上光/暗属性怪兽各1只
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c100037.target)
	e1:SetOperation(c100037.activate)
	c:RegisterEffect(e1)

	-- ② 墓地除外检索：从卡组拿「键刃-χ刃」(100051)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100037,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,100037)
	e2:SetCost(c100037.thcost)
	e2:SetTarget(c100037.thtg)
	e2:SetOperation(c100037.thop)
	c:RegisterEffect(e2)
end

-- 定义字段和关联卡ID
local SET_KEYBLADE = 0x208
local CARD_X_BLADE = 100051

--------------------------------------------------------------------------------
-- ① 仪式召唤核心逻辑
--------------------------------------------------------------------------------

-- 素材过滤器
-- 关键修正：加入 c:IsLevelAbove(1) 彻底排除超量(Rank)和连接(Link)怪兽
function c100037.matfilter(c)
	return c:IsFaceup() 
		and c:IsLevelAbove(1) 
		and c:IsReleasable() 
		and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end

-- 仪式怪兽过滤器
function c100037.rfilter(c,e,tp,mg)
	if not c:IsType(TYPE_RITUAL) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	-- 检查现在的素材组里，能否挑出满足条件的2张卡
	return mg:CheckSubGroup(c100037.matcheck,2,2,tp,c,c:GetLevel())
end

-- 核心检查算法：必须是1光1暗，且等级够
function c100037.matcheck(g,tp,rc,lv)
	-- 1. 必须是一光一暗
	if not (g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) 
		and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)) then return false end
	
	-- 2. 必须符合素材占用规则
	if not aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_MATERIAL) then return false end
	
	-- 3. 如果解放自己的卡，要确保还有格子放怪（解放双方卡时这个检查尤为重要）
	if Duel.GetMZoneCount(tp,g,tp)<=0 then return false end
	
	-- 4. 等级合计必须 >= 仪式怪兽等级
	return g:GetSum(Card.GetLevel) >= lv
end

function c100037.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取双方场上所有符合条件（有等级、光或暗、表侧）的素材
		local mg=Duel.GetMatchingGroup(c100037.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 检查手卡是否有可召唤的仪式怪兽
		return Duel.IsExistingMatchingCard(c100037.rfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function c100037.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取素材
	local mg=Duel.GetMatchingGroup(c100037.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	-- 1. 选仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,c100037.rfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	
	if tc then
		-- 如果仪式怪兽自己有特殊的素材限制（如“必须用XX怪兽”），进行二次过滤
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		end
		
		-- 2. 选素材：强制选2张，必须符合 check 逻辑
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=mg:SelectSubGroup(tp,c100037.matcheck,false,2,2,tp,tc,tc:GetLevel())
		
		if mat then
			tc:SetMaterial(mat)
			-- 因为可能涉及对方场上，用通用的 ReleaseRitualMaterial
			Duel.ReleaseRitualMaterial(mat)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

--------------------------------------------------------------------------------
-- ② 墓地检索逻辑
--------------------------------------------------------------------------------

-- Cost用过滤器：手卡的“键刃使”怪兽
function c100037.cfilter(c)
	return c:IsSetCard(SET_KEYBLADE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end

function c100037.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(c100037.cfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c100037.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- 检索目标：键刃-χ刃 (100051)
function c100037.thfilter(c)
	return c:IsCode(CARD_X_BLADE) and c:IsAbleToHand()
end

function c100037.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100037.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c100037.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100037.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end