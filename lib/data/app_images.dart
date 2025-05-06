class AppImages {
  // Stock photos paths
  static const airfryerFoodDishes = [
    'https://pixabay.com/get/ge4daf4d8b3888103941e57385b76fd08da95b412e87c7dce516ea8e019fb4b152c43c1ee6274064cbd93974c3469d445489648e2528ecc9dbc32a854680c2831_1280.jpg',
    'https://pixabay.com/get/gecf3e40da1e48f46f2dc52d3ec25edaf7bfdb54c8d0502c5961e574f3511e268b7ae8b9a5049123107d99afa5d2bf85f05b88cca2a75faf00c948944b1b5faec_1280.jpg',
    'https://pixabay.com/get/gb2f766d468de599ff16446db38d3f1abd40393712dcdfd74f2dd770d5a4a2db1124f5d18067bd4280f96353e2bf2d39a34600a070e8d0be60f28ad1bad60d1fd_1280.jpg',
    'https://pixabay.com/get/g98ab29ba4a20041190f012afaa94077e14da1b49604d40a27832190a4470b75f3e53c44775221ae8824651c9d40dde786cdc6f31dbabb1ad500b3a8728d90324_1280.jpg',
    'https://pixabay.com/get/g1721964b9ec788266780b8ab249d53772a8ea50e91e61cb677ecf98aa32ba9d238d4a15c336491edeaa00c412eb19790aa54ac12e6fcddd085d6f7fa33808a7a_1280.jpg',
    'https://pixabay.com/get/g0330321b11fde1ae8b33b429835a8fb9783c99b9da58de87325d06024837fd06346e2f63a1adbf60c93f8fd9dce5945e608b4d973e204d8bfcbc4667d5eaf11a_1280.jpg',
  ];

  static const modernFoodPhotography = [
    'https://pixabay.com/get/gedcaed6c9f02f6f96e85ba10e2e45ee4c36db144a815dac00feaca6bf21fef1af1ed9108d6b5ba6d5da02e055b6e7a44429a55307662a51b3b364275a3b01cb7_1280.jpg',
    'https://pixabay.com/get/g5212dce8db4434b65b4f804bb017688079a2164bba21858709a7849a5d3a270defbe4baedc00a8e390da60851b4fddb55f0c66d3e8500dcbc068df48068c5a36_1280.jpg',
    'https://pixabay.com/get/g64ee4cbf5d32f45a06100b8afeaef94c5f5732178d4879faa8f08cc187a2b8249a84a9f408e323006e818e6077909f96773e4bfecfb2761f182e5980df05968a_1280.jpg',
    'https://pixabay.com/get/gd91e66494ee7f60c1bfa5695d5433df5c0a0ea625635f2f4c14724fc2dd0910dd7c596dda7b457eda00b44a1b207026f10e67607ed24b19951787c87c96184ad_1280.jpg',
  ];

  static const cookingInterfaceDesigns = [
    'https://pixabay.com/get/ga8e32fbee7918ea084e3708a978f159315f34196cdfa42c3013b53b44f1e1ae1a923cdfedcab1f774b6e8f3492e3f73b0a507c13cec205101f74cf3703d8687c_1280.jpg',
    'https://pixabay.com/get/g15c8a8966fa885b40cc0c5ff599c5f139b34e7a3976f825eb02183e442cecc0855c6609a2e08b0237c10a2d30e7bf2690cda041394441db32f1ff2aeb7cd86cd_1280.jpg',
  ];

  // Default placeholder image
  static const placeholderImage = 'https://pixabay.com/get/ge4daf4d8b3888103941e57385b76fd08da95b412e87c7dce516ea8e019fb4b152c43c1ee6274064cbd93974c3469d445489648e2528ecc9dbc32a854680c2831_1280.jpg';

  // Get random food image
  static String getRandomFoodImage() {
    final allImages = [...airfryerFoodDishes, ...modernFoodPhotography];
    allImages.shuffle();
    return allImages.first;
  }

  // Category icons
  static const Map<String, String> categoryIcons = {
    'breakfast': '🍳',
    'lunch': '🥗',
    'dinner': '🍲',
    'snacks': '🍿',
    'desserts': '🍰',
    'sides': '🥦',
    'mains': '🍗',
    'healthy': '💪',
    'quick': '⏱️',
    'vegetarian': '🥑',
  };

  // App logos and icons
  static const appLogoPath = 'assets/images/app_logo.svg';
  static const appIconPath = 'assets/icons/app_icon.svg';

  // Asset paths for illustrations
  static const emptyStatePath = 'assets/illustrations/empty_state.svg';
  static const errorStatePath = 'assets/illustrations/error_state.svg';
  static const successPath = 'assets/illustrations/success.svg';
  static const cookingTimerPath = 'assets/illustrations/cooking_timer.svg';
  static const mealPlannerPath = 'assets/illustrations/meal_planner.svg';
}
