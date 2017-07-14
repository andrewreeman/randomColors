enum AccessCodeDataFlag: Int {
    case expireAfterDay = 1
}

public enum AccessCodeValidationResult: Error {
    case incorrectLength
    case keyMismatch
    case invalidData
    case couldNotCreatePrivateKeyFromUnlockCode
    case accessDataNotInteger // should never happen
    case ok
}

public class AccessCodeResult {
    
    private let m_validationResult: AccessCodeValidationResult
    public var result: AccessCodeValidationResult { return m_validationResult }
    
    private let m_data: AccessCodeData?
    public var data: AccessCodeData? { return m_data }
    
    init(WithResult: AccessCodeValidationResult, WithData: Int?) {
        m_validationResult = WithResult
        
        if let data = WithData {
            m_data = AccessCodeData(WithData: data)
        }
        else {
            m_data = nil
        }
    }
    
    convenience init(WithResult: AccessCodeValidationResult) {
        self.init(WithResult: WithResult, WithData: nil)
    }
}

public class AccessCodeData {
    
    private let m_data: Int
    public var expireAfterDay: Bool {
        return ( m_data & AccessCodeDataFlag.expireAfterDay.rawValue ) != 0
    }
    
    init(WithData: Int) {
        m_data = WithData
    }
}

public class UnlockCodeGenerator {
    public enum Zone: Int {
        case WelderLogin = 1
        case PasswordReset = 2
        case LoginBypass = 3
        case Diagnostics = 4
        case QueueLimit = 5
        case BDIUnlockCode = 6
        case BDICustom = 7
        case UpdateBypass = 8
        case GPSBypass = 9
    }
    
    public static func generateUnlockCodeForZone(_ zone: Zone) -> Int {
        let part1 = ((Int(arc4random_uniform(8)) + 1) * 10) + zone.rawValue
        let part2 = Int(arc4random_uniform(99-10)) + 10
        let part3 = ((Int(arc4random_uniform(8)) + 1) * 10) + zone.rawValue
        let publicKeyString = "\(part1)\(part2)\(part3)"
        
        return Int(publicKeyString)!
    }
}

public class AccessCodeDecoder {
    // MARK: private static constants
    private static let MAX_STANDARD_ACCESS_CODE_FIRST_PART_SIZE = 355
    
    // MARK: public static methods
    
    /*
        split into two parts
     
        check first 3 digits. If above 355 then it is a special access code with data

        if special then continue

        sum firstPart digits
        key = secondPart - firstPartSum

        if key is below zero
        then key is 1000 - abs(key)

        get standard access code from unlock code
        the unlockCodeKey will add and mod every two digits of the standard access code

        validate by comparing key to unlockCodeKey

        get data by removing offset from firstPart
     */
    public static func decode(AccessCode: Int, ForUnlockCode: Int) -> AccessCodeResult {
        if isAccess(CodeWithData: AccessCode) {
            return decode(AsAccessCodeWithData: AccessCode, ForUnlockCode: ForUnlockCode)
        }
        else {
            return decode(AsStandardAccessCode: AccessCode, ForUnlockCode: ForUnlockCode)
        }
    }
    
    public static func createStandardAccessCode(_ unlockCode: Int) -> Int? {
        let strUnlockCode = String.init(unlockCode)
        guard strUnlockCode.characters.count >= 6 else { return nil }
        
        let part1Range = strUnlockCode.startIndex ..< strUnlockCode.characters.index(strUnlockCode.startIndex, offsetBy: 2)
        let part2Range = strUnlockCode.characters.index(strUnlockCode.startIndex, offsetBy: 2) ..< strUnlockCode.characters.index(strUnlockCode.startIndex, offsetBy: 4)
        let part3Range = strUnlockCode.characters.index(strUnlockCode.startIndex, offsetBy: 4) ..< strUnlockCode.characters.index(strUnlockCode.startIndex, offsetBy: 6)
        if let part1 = Int(strUnlockCode[part1Range]), let part2 = Int(strUnlockCode[part2Range]), let part3 = Int(strUnlockCode[part3Range]) {
            let partA = ((part1 * part2) % 256) + 100
            let partB = ((part1 * part3) % 256) + partA
            
            return Int("\(partA)\(partB)")
        }
        else {
            return nil
        }
    }

    // MARK: private static methods
    private static func decode(AsAccessCodeWithData accessCode: Int, ForUnlockCode: Int) -> AccessCodeResult {
        let accessCodeString = "\(accessCode)"
        guard validateLength(OfCode: accessCodeString) else {
            return AccessCodeResult.init(WithResult: .incorrectLength)
        }
        
        let firstPart = accessCodeString.substring(to: 2)
        guard let firstPartInt = Int(firstPart) else {
            return AccessCodeResult.init(WithResult: .accessDataNotInteger)
        }
        
        guard let standardAccessCodeForUnlockCode = createStandardAccessCode(ForUnlockCode)
            else
        {
            return AccessCodeResult.init(WithResult: .couldNotCreatePrivateKeyFromUnlockCode)
        }
        
        let secondPart = accessCodeString.substring(from: 3, to: 5)
        guard let secondPartInt = Int(secondPart) else {
            return AccessCodeResult.init(WithResult: .accessDataNotInteger)
        }
        
        let firstPartSummation = sum(Data: firstPart)
        let key = getKey(FromSecondPart: secondPartInt, AndFirstPartSum: firstPartSummation)
        let unlockCodeKey = addAndModEveryTwoDigits(ForAccessCode: standardAccessCodeForUnlockCode)
        
        if key != unlockCodeKey {
            return AccessCodeResult.init(WithResult: .keyMismatch)
        }
        
        
        
        // remove offset from the data
        let firstPartData = firstPartInt - MAX_STANDARD_ACCESS_CODE_FIRST_PART_SIZE
        return AccessCodeResult.init(WithResult: .ok, WithData: firstPartData)
    }
    
    private static func decode(AsStandardAccessCode accessCode: Int, ForUnlockCode: Int) -> AccessCodeResult {
        guard let privateKey = createStandardAccessCode(ForUnlockCode) else {
            return AccessCodeResult.init(WithResult: .couldNotCreatePrivateKeyFromUnlockCode)
        }
        
        if accessCode == privateKey {
            return AccessCodeResult.init(WithResult: .ok)
        }
        else {
            return AccessCodeResult.init(WithResult: .keyMismatch)
        }
    }
    
    private static func sum(Data: String) -> Int {
        let digits = Data.digitList
        return digits.sum
    }
    
    private static func getKey(FromSecondPart: Int, AndFirstPartSum: Int) -> Int {
        let key = FromSecondPart - AndFirstPartSum
        if key < 0 {
            return 1000 - abs(key)
        }
        return key
    }
    
    private static func addAndModEveryTwoDigits(ForAccessCode: Int) -> Int {
        let pairs = ForAccessCode.digitList.pairs
        let pairSums: [Int] = pairs.map {
            let result = ($0.0 + $0.1) % 10
            return result == 0 ? 1 : result
        }
        
        return pairSums.joinToSingleInt ?? 0
    }
    
    private static func isAccess(CodeWithData: Int) -> Bool {
        let accessCodeString = "\(CodeWithData)"
        guard validateLength(OfCode: accessCodeString) else { return false }
        
        let firstPart = accessCodeString.substring(to: 2)
        if let firstPartNumber = Int.init(firstPart) {
            return firstPartNumber > MAX_STANDARD_ACCESS_CODE_FIRST_PART_SIZE
        }
        else {
            return false
        }
    }
    private static func  validateLength(OfCode: String) -> Bool {
        return OfCode.characters.count >= 6
    }
}
