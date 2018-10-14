import 'dart:async';
import 'package:Openbook/services/auth-api.dart';
import 'package:Openbook/services/localization.dart';
import 'package:Openbook/services/validation.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:sprintf/sprintf.dart';

class CreateAccountBloc {
  ValidationService _validationService;
  LocalizationService _localizationService;
  AuthApiService _authApiService;

  // Serves as a snapshot to the data
  final userRegistrationData = UserRegistrationData();

  // Birthday begins

  Sink<DateTime> get birthday => _birthdayController.sink;
  final _birthdayController = StreamController<DateTime>();

  Stream<bool> get birthdayIsValid => _birthdayIsValidSubject.stream;

  final _birthdayIsValidSubject = BehaviorSubject<bool>();

  Stream<String> get birthdayFeedback => _birthdayFeedbackSubject.stream;

  final _birthdayFeedbackSubject = BehaviorSubject<String>();

  Stream<String> get validatedBirthday => _validatedBirthdaySubject.stream;

  final _validatedBirthdaySubject = BehaviorSubject<String>();

  // Birthday ends

  // Name begins

  Sink<String> get name => _nameController.sink;
  final _nameController = StreamController<String>();

  Stream<bool> get nameIsValid => _nameIsValidSubject.stream;

  final _nameIsValidSubject = BehaviorSubject<bool>();

  Stream<String> get nameFeedback => _nameFeedbackSubject.stream;

  final _nameFeedbackSubject = BehaviorSubject<String>();

  Stream<String> get validatedName => _validatedNameSubject.stream;

  final _validatedNameSubject = BehaviorSubject<String>();

  // Name ends

  // Username begins

  Stream<bool> get usernameIsValid => _usernameIsValidSubject.stream;

  final _usernameIsValidSubject = BehaviorSubject<bool>();

  Stream<String> get usernameFeedback => _usernameFeedbackSubject.stream;

  final _usernameFeedbackSubject = BehaviorSubject<String>();

  Stream<String> get validatedUsername => _validatedUsernameSubject.stream;

  final _validatedUsernameSubject = BehaviorSubject<String>();

  // Username ends

  // Email begins

  Sink<String> get email => _emailController.sink;
  final _emailController = StreamController<String>();

  Stream<bool> get emailIsValid => _emailIsValidSubject.stream;

  final _emailIsValidSubject = BehaviorSubject<bool>();

  Stream<String> get emailFeedback => _emailFeedbackSubject.stream;

  final _emailFeedbackSubject = BehaviorSubject<String>();

  Stream<String> get validatedEmail => _validatedEmailSubject.stream;

  final _validatedEmailSubject = BehaviorSubject<String>();

  StreamSubscription<Response> _emailCheckSub;

  // Email ends

  // Password begins

  Sink<String> get password => _passwordController.sink;
  final _passwordController = StreamController<String>();

  Stream<bool> get passwordIsValid => _passwordIsValidSubject.stream;

  final _passwordIsValidSubject = BehaviorSubject<bool>();

  Stream<String> get passwordFeedback => _passwordFeedbackSubject.stream;

  final _passwordFeedbackSubject = BehaviorSubject<String>();

  Stream<String> get validatedPassword => _validatedPasswordSubject.stream;

  final _validatedPasswordSubject = BehaviorSubject<String>();

  // Password ends

  // Avatar begins

  Sink<File> get avatar => _avatarController.sink;
  final _avatarController = StreamController<File>();

  Stream<bool> get avatarIsValid => _avatarIsValidSubject.stream;

  final _avatarIsValidSubject = BehaviorSubject<bool>();

  Stream<String> get avatarFeedback => _avatarFeedbackSubject.stream;

  final _avatarFeedbackSubject = BehaviorSubject<String>();

  Stream<File> get validatedAvatar => _validatedAvatarSubject.stream;

  final _validatedAvatarSubject = BehaviorSubject<File>();

  // Avatar ends

  // Create account begins

  Stream<bool> get createAccountInProgress =>
      _createAccountInProgressSubject.stream;

  final _createAccountInProgressSubject = BehaviorSubject<bool>();

  Stream<String> get createAccountErrorFeedback =>
      _createAccountErrorFeedbackSubject.stream;

  final _createAccountErrorFeedbackSubject = BehaviorSubject<String>();

  // Create account ends

  CreateAccountBloc() {
    _emailController.stream.listen(_onEmail);
    _nameController.stream.listen(_onName);
    _passwordController.stream.listen(_onPassword);
    _birthdayController.stream.listen(_onBirthday);
    _avatarController.stream.listen(_onAvatar);
  }

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setValidationService(ValidationService validationService) {
    _validationService = validationService;
  }

  void setAuthApiService(AuthApiService authApiService) {
    _authApiService = authApiService;
  }

  // Birthday begins

  bool hasBirthday() {
    return userRegistrationData.birthday != null;
  }

  String getBirthday() {
    return userRegistrationData.birthday;
  }

  void _onBirthday(DateTime birthday) {
    _clearBirthday();

    if (birthday == null) {
      _onBirthdayIsEmpty();
      return;
    }

    if (!_validationService.isValidBirthday(birthday)) {
      _onBirthdayIsInvalid();
      return;
    }

    _onBirthdayIsValid(birthday);
  }

  void _onBirthdayIsEmpty() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.BIRTHDAY_EMPTY_ERROR');
    _birthdayFeedbackSubject.add(errorFeedback);
  }

  void _onBirthdayIsInvalid() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.BIRTHDAY_INVALID_ERROR');
    _birthdayFeedbackSubject.add(errorFeedback);
  }

  void _onBirthdayIsValid(DateTime birthday) {
    String parsedDate = DateFormat('dd-MM-yyyy').format(birthday);

    _birthdayFeedbackSubject.add(null);
    userRegistrationData.birthday = parsedDate;
    _validatedBirthdaySubject.add(parsedDate);
    _birthdayIsValidSubject.add(true);
  }

  void _clearBirthday() {
    _birthdayIsValidSubject.add(false);
    _validatedBirthdaySubject.add(null);
    userRegistrationData.birthday = null;
  }

  // Birthday ends

  // Name begins

  bool hasName() {
    return userRegistrationData.name != null;
  }

  String getName() {
    return userRegistrationData.name;
  }

  void _onName(String name) {
    _clearName();

    if (name == null || name.isEmpty) {
      _onNameIsEmpty();
      return;
    }

    if (name.length > 50) {
      _onNameTooLong();
      return;
    }

    if (!_validationService.isAlphanumericWithSpaces(name)) {
      _onNameInvalidCharacters();
      return;
    }

    _onNameIsValid(name);
  }

  void _onNameIsEmpty() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.NAME_EMPTY_ERROR');
    _nameFeedbackSubject.add(errorFeedback);
  }

  void _onNameTooLong() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.NAME_MAX_LENGTH_ERROR');
    _nameFeedbackSubject.add(errorFeedback);
  }

  void _onNameInvalidCharacters() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.NAME_CHARACTERS_ERROR');
    _nameFeedbackSubject.add(errorFeedback);
  }

  void _onNameIsValid(String name) {
    _nameFeedbackSubject.add(null);

    userRegistrationData.name = name;
    _validatedNameSubject.add(name);
    _nameIsValidSubject.add(true);
  }

  void _clearName() {
    _nameIsValidSubject.add(false);
    _validatedNameSubject.add(null);
    userRegistrationData.name = null;
  }

  // Name ends

  // Username begins

  bool hasUsername() {
    return userRegistrationData.username != null;
  }

  String getUsername() {
    return userRegistrationData.username;
  }

  Future<bool> setUsername(String username) async {
    clearUsername();

    if (username == null || username.isEmpty) {
      _onUsernameIsEmpty();
      return Future.value(false);
    }

    if (username.length > 50) {
      _onUsernameTooLong();
      return Future.value(false);
    }

    if (!_validationService.isAlphanumericWithUnderscores(username)) {
      _onUsernameInvalidCharacters();
      return Future.value(false);
    }

    return _checkUsernameIsAvailable(username).then((Response response){
      if (response.statusCode == HttpStatus.accepted) {
        _onUsernameIsAvailable(username);
        return true;
      } else if (response.statusCode == HttpStatus.badRequest) {
        _onUsernameIsNotAvailable(username);
        return false;
      } else {
        _onUsernameCheckServerError();
        return false;
      }
    }).catchError((error){
      _onUsernameCheckServerError();
    });
  }

  void _onUsernameIsEmpty() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.USERNAME_EMPTY_ERROR');
    _usernameFeedbackSubject.add(errorFeedback);
  }

  void _onUsernameTooLong() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.USERNAME_MAX_LENGTH_ERROR');
    _usernameFeedbackSubject.add(errorFeedback);
  }

  void _onUsernameInvalidCharacters() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.USERNAME_CHARACTERS_ERROR');
    _usernameFeedbackSubject.add(errorFeedback);
  }

  void _onUsernameIsAvailable(String username) {
    _usernameFeedbackSubject.add(null);

    _onUsernameIsValid(username);
  }

  void _onUsernameIsNotAvailable(String username) {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.USERNAME_TAKEN_ERROR');

    String parsedFeedback = sprintf(errorFeedback, [username]);
    _usernameFeedbackSubject.add(parsedFeedback);
  }

  void _onUsernameCheckServerError() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.USERNAME_SERVER_ERROR');
    _usernameFeedbackSubject.add(errorFeedback);
  }

  void clearUsername() {
    _usernameFeedbackSubject.add(null);
    _usernameIsValidSubject.add(false);
    _validatedUsernameSubject.add(null);
    userRegistrationData.username = null;
  }

  void _onUsernameIsValid(String username) {
    userRegistrationData.username = username;
    _validatedUsernameSubject.add(username);
    _usernameIsValidSubject.add(true);
  }

  Future<Response> _checkUsernameIsAvailable(String username) {
    return _authApiService.checkUsernameIsAvailable(username: username);
  }

  // Username ends

  // Email begins

  bool hasEmail() {
    return userRegistrationData.email != null;
  }

  String getEmail() {
    return userRegistrationData.email;
  }

  void _onEmail(String email) {
    _clearEmail();

    if (email == null || email.isEmpty) {
      _onEmailIsEmpty();
      return;
    }

    if (!_validationService.isQualifiedEmail(email)) {
      _onEmailIsNotQualifiedEmail();
      return;
    }

    _emailCheckSub =
        _checkEmailIsAvailable(email).asStream().listen((Response response) {
      if (response.statusCode == HttpStatus.accepted) {
        _onEmailIsAvailable(email);
      } else if (response.statusCode == HttpStatus.badRequest) {
        _onEmailIsNotAvailable(email);
      } else {
        _onEmailCheckServerError();
      }
    });
  }

  void _onEmailIsEmpty() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_EMPTY_ERROR');
    _emailFeedbackSubject.add(errorFeedback);
  }

  void _onEmailIsNotQualifiedEmail() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_INVALID_ERROR');
    _emailFeedbackSubject.add(errorFeedback);
  }

  void _onEmailIsNotAvailable(String email) {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_TAKEN_ERROR');

    String parsedFeedback = sprintf(errorFeedback, [email]);
    _emailFeedbackSubject.add(parsedFeedback);
  }

  void _onEmailIsAvailable(String email) {
    String feedback =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_SUCCESS');
    _emailFeedbackSubject.add(feedback);

    _onEmailIsValid(email);
  }

  void _onEmailIsValid(String email) {
    userRegistrationData.email = email;
    _validatedEmailSubject.add(email);
    _emailIsValidSubject.add(true);
  }

  Future<Response> _checkEmailIsAvailable(String email) async {
    String progressFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_CHECK');
    _emailFeedbackSubject.add(progressFeedback);

    return _authApiService.checkEmailIsAvailable(email: email);
  }

  void _onEmailCheckServerError() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_SERVER_ERROR');
    _emailFeedbackSubject.add(errorFeedback);
  }

  void _clearEmail() {
    if (_emailCheckSub != null) {
      _emailCheckSub.cancel();
      _emailCheckSub = null;
    }

    _emailIsValidSubject.add(false);
    _validatedEmailSubject.add(null);
    userRegistrationData.email = null;
  }

  // Email ends

  // Password begins

  bool hasPassword() {
    return userRegistrationData.password != null;
  }

  String getPassword() {
    return userRegistrationData.password;
  }

  void _onPassword(String password) {
    _clearPassword();

    if (password == null || password.isEmpty) {
      _onPasswordIsEmpty();
      return;
    }

    if (password.length < 8) {
      _onPasswordTooSmall();
      return;
    }

    if (password.length > 64) {
      _onPasswordTooLong();
      return;
    }

    _onPasswordIsValid(password);
  }

  void _onPasswordIsEmpty() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.PASSWORD_EMPTY_ERROR');
    _passwordFeedbackSubject.add(errorFeedback);
  }

  void _onPasswordTooSmall() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.PASSWORD_MIN_LENGTH_ERROR');
    _passwordFeedbackSubject.add(errorFeedback);
  }

  void _onPasswordTooLong() {
    String errorFeedback =
        _localizationService.trans('AUTH.CREATE_ACC.PASSWORD_MIN_LENGTH_ERROR');
    _passwordFeedbackSubject.add(errorFeedback);
  }

  void _onPasswordIsValid(String password) {
    _passwordFeedbackSubject.add(null);

    userRegistrationData.password = password;
    _validatedPasswordSubject.add(password);
    _passwordIsValidSubject.add(true);
  }

  void _clearPassword() {
    _passwordIsValidSubject.add(false);
    _validatedPasswordSubject.add(null);
    userRegistrationData.password = null;
  }

// Password ends

  // Avatar begins

  bool hasAvatar() {
    return userRegistrationData.avatar != null;
  }

  File getAvatar() {
    return userRegistrationData.avatar;
  }

  void _onAvatar(File avatar) {
    _clearAvatar();

    if (avatar == null) {
      // Avatar is optional, therefore no feedback to user.
      return;
    }

    _onAvatarIsValid(avatar);
  }

  void _onAvatarIsValid(File avatar) {
    userRegistrationData.avatar = avatar;
    _validatedAvatarSubject.add(avatar);
    _avatarIsValidSubject.add(true);
  }

  void _clearAvatar() {
    _avatarIsValidSubject.add(false);
    _validatedAvatarSubject.add(null);
    if(userRegistrationData.avatar != null){
      userRegistrationData.avatar.deleteSync();
    }
    userRegistrationData.avatar = null;
  }

// Email ends

  Future<bool> createAccount() {
    _clearCreateAccount();

    _createAccountInProgressSubject.add(true);

    return _authApiService
        .createAccount(
            email: userRegistrationData.email,
            username: userRegistrationData.username,
            name: userRegistrationData.name,
            birthDate: userRegistrationData.birthday,
            password: userRegistrationData.password,
            avatar: userRegistrationData.avatar)
        .then((StreamedResponse response) {
      if (response.statusCode == HttpStatus.created) {
        return true;
      }

      String errorFeedback;

      if (response.statusCode == HttpStatus.badRequest) {
        // Validation errors.
        // TODO Display specific validation errors.
        errorFeedback = _localizationService
            .trans('AUTH.CREATE_ACC.SUBMIT_ERROR_DESC_VALIDATION');
      } else {
        // Server error
        errorFeedback = _localizationService
            .trans('AUTH.CREATE_ACC.SUBMIT_ERROR_DESC_SERVER');
      }

      _createAccountErrorFeedbackSubject.add(errorFeedback);

      return false;
    });
  }

  void _clearCreateAccount() {
    _createAccountInProgressSubject.add(null);
    _createAccountErrorFeedbackSubject.add(null);
  }

  void clearAll(){
    _clearCreateAccount();
    _clearBirthday();
    _clearName();
    _clearEmail();
    _clearAvatar();
    clearUsername();
  }
}

class UserRegistrationData {
  String name;
  String birthday;
  String username;
  String email;
  String password;
  File avatar;
}
