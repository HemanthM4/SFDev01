//
// The supplied json has fields with names that are not valid in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

public class TrustpilotJSON2Apex { 

	public class Reviews {
		public List<Links> links {get;set;} 
		public String id {get;set;} 
		public Consumer consumer {get;set;} 
		public BusinessUnit businessUnit {get;set;} 
		public Integer stars {get;set;} 
		public String title {get;set;} 
		public String text1 {get;set;} 
		public String language {get;set;} 
		public String location {get;set;} 
		public String createdAt {get;set;} 
		public String updatedAt {get;set;} 
		public String referralEmail {get;set;} 
		public String referenceId {get;set;} 
		public String source {get;set;} 
		public CompanyReply companyReply {get;set;} 
		public List<Tags> tags {get;set;} 
		public Integer numberOfLikes {get;set;} 
		public FindReviewer findReviewer {get;set;} 
		public Boolean isVerified {get;set;} 
		public String status {get;set;} 
		public String reportData {get;set;} 
		public Boolean countsTowardsTrustScore {get;set;} 
		public String countsTowardsLocationTrustScore {get;set;} 
		public Invitation invitation {get;set;} 
		public List<Requests> businessUnitHistory {get;set;} 
		public String reviewVerificationLevel {get;set;} 

		public Reviews(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'links') {
							links = arrayOfLinks(parser);
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'consumer') {
							consumer = new Consumer(parser);
						} else if (text == 'businessUnit') {
							businessUnit = new BusinessUnit(parser);
						} else if (text == 'stars') {
							stars = parser.getIntegerValue();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'text') {
							text1 = parser.getText();
						} else if (text == 'language') {
							language = parser.getText();
						} else if (text == 'location') {
							location = parser.getText();
						} else if (text == 'createdAt') {
							createdAt = parser.getText();
						} else if (text == 'updatedAt') {
							updatedAt = parser.getText();
						} else if (text == 'referralEmail') {
							referralEmail = parser.getText();
						} else if (text == 'referenceId') {
							referenceId = parser.getText();
						} else if (text == 'source') {
							source = parser.getText();
						} else if (text == 'companyReply') {
							companyReply = new CompanyReply(parser);
						} else if (text == 'tags') {
							tags = arrayOfTags(parser);
						} else if (text == 'numberOfLikes') {
							numberOfLikes = parser.getIntegerValue();
						} else if (text == 'findReviewer') {
							findReviewer = new FindReviewer(parser);
						} else if (text == 'isVerified') {
							isVerified = parser.getBooleanValue();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'reportData') {
							reportData = parser.getText();
						} else if (text == 'countsTowardsTrustScore') {
							countsTowardsTrustScore = parser.getBooleanValue();
						} else if (text == 'countsTowardsLocationTrustScore') {
							countsTowardsLocationTrustScore = parser.getText();
						} else if (text == 'invitation') {
							invitation = new Invitation(parser);
						} else if (text == 'businessUnitHistory') {
							businessUnitHistory = arrayOfRequests(parser);
						} else if (text == 'reviewVerificationLevel') {
							reviewVerificationLevel = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'Reviews consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Links> links {get;set;} 
	public List<Reviews> reviews {get;set;} 

	public TrustpilotJSON2Apex(JSONParser parser) { 
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'links') {
						links = arrayOfLinks(parser);
					} else if (text == 'reviews') {
						reviews = arrayOfReviews(parser);
					} else {
					//	System.debug(LoggingLevel.WARN, 'TrustpilotJSON2Apex consuming unrecognized property: '+text); 
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Consumer {
		public List<Links> links {get;set;} 
		public String id {get;set;} 
		public String displayName {get;set;} 
		public String displayLocation {get;set;} 
		public Integer numberOfReviews {get;set;} 

		public Consumer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'links') {
							links = arrayOfLinks(parser);
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else if (text == 'displayLocation') {
							displayLocation = parser.getText();
						} else if (text == 'numberOfReviews') {
							numberOfReviews = parser.getIntegerValue();
						} else {
						//	System.debug(LoggingLevel.WARN, 'Consumer consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CompanyReply_Z {
		public String text1 {get;set;} 
		public String authorBusinessUserId {get;set;} 
		public String authorBusinessUserName {get;set;} 
		public String createdAt {get;set;} 
		public String updatedAt {get;set;} 

		public CompanyReply_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'text') {
							text1 = parser.getText();
						} else if (text == 'authorBusinessUserId') {
							authorBusinessUserId = parser.getText();
						} else if (text == 'authorBusinessUserName') {
							authorBusinessUserName = parser.getText();
						} else if (text == 'createdAt') {
							createdAt = parser.getText();
						} else if (text == 'updatedAt') {
							updatedAt = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'CompanyReply_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BusinessUnit {
		public List<Links> links {get;set;} 
		public String id {get;set;} 
		public String identifyingName {get;set;} 
		public String displayName {get;set;} 

		public BusinessUnit(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'links') {
							links = arrayOfLinks(parser);
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'identifyingName') {
							identifyingName = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'BusinessUnit consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CompanyReply {
		public String text1 {get;set;} 
		public String authorBusinessUserId {get;set;} 
		public String authorBusinessUserName {get;set;} 
		public String createdAt {get;set;} 
		public String updatedAt {get;set;} 

		public CompanyReply(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'text') {
							text1 = parser.getText();
						} else if (text == 'authorBusinessUserId') {
							authorBusinessUserId = parser.getText();
						} else if (text == 'authorBusinessUserName') {
							authorBusinessUserName = parser.getText();
						} else if (text == 'createdAt') {
							createdAt = parser.getText();
						} else if (text == 'updatedAt') {
							updatedAt = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'CompanyReply consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Invitation {
		public String businessUnitId {get;set;} 

		public Invitation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessUnitId') {
							businessUnitId = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'Invitation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Links {
		public String href {get;set;} 
		public String method {get;set;} 
		public String rel {get;set;} 

		public Links(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'href') {
							href = parser.getText();
						} else if (text == 'method') {
							method = parser.getText();
						} else if (text == 'rel') {
							rel = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'Links consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Requests {

		public Requests(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
						//	System.debug(LoggingLevel.WARN, 'Requests consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class FindReviewer {
		public Boolean isEligible {get;set;} 
		public List<Requests> requests {get;set;} 

		public FindReviewer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'isEligible') {
							isEligible = parser.getBooleanValue();
						} else if (text == 'requests') {
							requests = arrayOfRequests(parser);
						} else {
						//	System.debug(LoggingLevel.WARN, 'FindReviewer consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Tags {
		public String group_Z {get;set;} // in json: group
		public String value {get;set;} 

		public Tags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'group') {
							group_Z = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else {
						//	System.debug(LoggingLevel.WARN, 'Tags consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static TrustpilotJSON2Apex parse(String json) { 
		System.JSONParser parser = System.JSON.createParser(json);
		return new TrustpilotJSON2Apex(parser); 
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	








    private static List<Requests> arrayOfRequests(System.JSONParser p) {
        List<Requests> res = new List<Requests>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Requests(p));
        }
        return res;
    }





    private static List<Links> arrayOfLinks(System.JSONParser p) {
        List<Links> res = new List<Links>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Links(p));
        }
        return res;
    }






    private static List<Reviews> arrayOfReviews(System.JSONParser p) {
        List<Reviews> res = new List<Reviews>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Reviews(p));
        }
        return res;
    }


    private static List<Tags> arrayOfTags(System.JSONParser p) {
        List<Tags> res = new List<Tags>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Tags(p));
        }
        return res;
    }



}