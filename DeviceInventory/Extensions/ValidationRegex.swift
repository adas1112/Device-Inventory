

import Foundation

extension String{
    
    public func validateEmailAddress() -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return applyPredicateRegex(regexStr: emailRegex)
    }
    
    func validatePassword () -> Bool{
        //minimum 4 character and 4 number
        let passwordRegex = "^[a-zA-Z]{4,}[0-9]{4,}$"
        return applyPredicateRegex(regexStr: passwordRegex)
    }
    
    
    
    func applyPredicateRegex(regexStr : String) -> Bool{
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        let validateString = NSPredicate(format:"SELF MATCHES %@",regexStr)
        let isvalidateString = validateString.evaluate(with: trimmedString)
        return isvalidateString
    }
}
