FactoryGirl.define do
  factory :card_script_submission do
    comment "factory comment"

    config <<-EOF
name=Akroma, Angel of Wrath
url=http://magiccards.info/dvd/en/1.html
image=http://magiccards.info/scans/en/tsts/1.jpg
value=4.605
rarity=M
type=Legendary,Creature
subtype=Angel
cost={5}{W}{W}{W}
pt=6/6
ability=flying,first strike,vigilance,trample,haste,protection from black,protection from red
timing=fmain
    EOF
    script <<-EOF
[
    new MagicWhenBlocksOrBecomesBlockedTrigger() {
        @Override
        public MagicEvent executeTrigger(final MagicGame game,final MagicPermanent permanent,final MagicPermanent blocker) {
            final MagicPermanent target = permanent == blocker ? blocker.getBlockedCreature() : blocker;
            return (target.hasColor(MagicColor.White) || target.hasColor(MagicColor.Green)) ?
                new MagicEvent(
                    permanent,
                    target,
                    this,
                    "Destroy RN at end of combat."
                ):
                MagicEvent.NONE;
        }
        @Override
        public void executeEvent(final MagicGame game, final MagicEvent event) {
            event.processRefPermanent(game, {
                game.doAction(new MagicAddTurnTriggerAction(
                    it,
                    MagicAtEndOfCombatTrigger.Destroy
                ))
            });
        }
    }
]
    EOF

    pushed false
  end
end
