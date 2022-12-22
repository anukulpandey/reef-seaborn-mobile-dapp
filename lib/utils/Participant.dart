class Participant{
    String? nameOfParticipant;
    String? walletAddress;
    
    Map<String,dynamic>? ParticipantDataMap;

    Participant(this.nameOfParticipant,this.walletAddress){
      ParticipantDataMap = {
        "name":nameOfParticipant,
        "address":walletAddress
      };
    }
}