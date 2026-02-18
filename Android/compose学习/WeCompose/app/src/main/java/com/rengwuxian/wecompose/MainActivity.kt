package com.rengwuxian.wecompose

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.core.view.WindowCompat
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.viewmodel.navigation3.rememberViewModelStoreNavEntryDecorator
import androidx.navigation3.runtime.entry
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.runtime.rememberSavedStateNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import androidx.navigation3.ui.rememberSceneSetupNavEntryDecorator
import com.rengwuxian.wecompose.ui.ChatDetails
import com.rengwuxian.wecompose.ui.ChatDetailsPage
import com.rengwuxian.wecompose.ui.Home
import com.rengwuxian.wecompose.ui.HomePage
import com.rengwuxian.wecompose.ui.theme.WeComposeTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
  val viewModel: WeViewModel by viewModels()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    val insetsController = WindowCompat.getInsetsController(window, window.decorView)

    lifecycleScope.launch {
      viewModel.isLightThemeFlow.collect {
        insetsController.isAppearanceLightStatusBars = it
      }
    }

    setContent {
      WeComposeTheme(viewModel.theme) {
        val backStack = rememberNavBackStack(Home)
        NavDisplay(
          backStack,
          entryDecorators = listOf(
            rememberSceneSetupNavEntryDecorator(),
            rememberSavedStateNavEntryDecorator(),
            rememberViewModelStoreNavEntryDecorator()
          ),
          transitionSpec = {
            slideInHorizontally(initialOffsetX = { it }) togetherWith
                slideOutHorizontally(targetOffsetX = { - it / 2 })
          },
          popTransitionSpec = {
            slideInHorizontally(initialOffsetX = { - it / 2 }) togetherWith
                slideOutHorizontally(targetOffsetX = { it })
          },
          predictivePopTransitionSpec = {
            slideInHorizontally(initialOffsetX = { - it / 2 }) togetherWith
                slideOutHorizontally(targetOffsetX = { it })
          },
          entryProvider = entryProvider {
            entry<Home> { HomePage(viewModel) { backStack.add(ChatDetails(it.friend.id)) } }
            entry<ChatDetails> { ChatDetailsPage(viewModel, it.userId) }
          })
      }
    }
  }
}