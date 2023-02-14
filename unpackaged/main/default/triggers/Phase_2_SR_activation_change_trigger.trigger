trigger Phase_2_SR_activation_change_trigger on ServiceResource ( before update ) 
{
  if(Trigger.isBefore && Trigger.isUpdate){
       //Phase_2_SR_activation_change_controller.beforeUpdate(Trigger.new,Trigger.oldMap);
    }
}