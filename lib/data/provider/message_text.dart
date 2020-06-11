import 'login_messages.dart';

class MessageText {
  LoginMessages messages = LoginMessages(
    usernameHint: 'Email Address',
    passwordHint: 'Password',
    confirmPasswordHint: 'Confirm',
    resendVerificationButton: 'Resend Email',
    loginButton: 'Login',
    verifyEmailLabel: 'Please verify your email address. Once completed, press Continue',
    verifyEmailButton: 'Complete',
    signupButton: 'Register',
    forgotPasswordButton: 'Reset Password',
    recoverPasswordButton: 'Reset!',
    goBackButton: 'Go Back',
    confirmPasswordError: 'Not matching!',
    recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
    recoverPasswordDescription: 'To reset your password, please enter your email address.',
    recoverPasswordSuccess: 'Password reset request has been sent.',
  );
}
