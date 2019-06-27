# reactions.rb

class Daedalus
  def react o = {}
    # options = {
    #   :user => user's id
    #   :item => name of the item whose reaction is being invoked
    #   :room => room in which the reaction is taking place
    #   :type => name of reaction
    # }

    if !o[:user].nil?
      if o[:type] == "take"
        if o[:item] == "pamphlet"
          if o[:room] == 0
            $system.utils.store_message FORMAT("You grab the pamphlet, and then put it back, realizing that there's no point in carrying around a loose piece of paper.")
          end
        end
      elsif o[:type] == "pet"
        if o[:item] == "ctesiphus"
          msg = ""
          msg << "You pet Ctesiphus for good luck.\nCtesiphus says, 'Meow.'."
          unless $system.utils.check_effect o[:user], "glowing"
            msg << "\nYou start to glow."
          end
          $system.utils.afflict o[:user], "glowing"
          $system.utils.store_message FORMAT(msg)
        end
      elsif o[:type] == "read"
        if o[:item] == "pamphlet" && o[:room] == 0
          msg = ""
          msg << "#{$system.world.items["pamphlet"]["symbol"]} You read the pamphlet.\n.\n"
          msg << "❝But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?❞"
          $system.utils.store_message FORMAT(msg)
        end
      end
    end
    LOG :info, "Invoked reaction with options:"
    o.each { |op| LOG :info, "#{" "*2}#{op[0]}: #{op[1]}" }
  end
end
