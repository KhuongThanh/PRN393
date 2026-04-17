using E_Learning.Domain.Quiz.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace E_Learning.Domain.Quiz.Controllers
{
    [Route("api/quiz-attempts")]
    [ApiController]
    [Authorize]
    public class QuizResultController : ControllerBase
    {
        private readonly IQuizResultService _quizResultService;

        public QuizResultController(IQuizResultService quizResultService)
        {
            _quizResultService = quizResultService;
        }

        [HttpGet("{attemptId:guid}/result")]
        public async Task<IActionResult> GetResult(Guid attemptId)
        {
            var userId = GetCurrentUserId();
            var result = await _quizResultService.GetQuizResultAsync(attemptId, userId);
            return Ok(result);
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory()
        {
            var userId = GetCurrentUserId();
            var result = await _quizResultService.GetMyQuizHistoryAsync(userId);
            return Ok(result);
        }

        private Guid GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("userId")?.Value
                              ?? User.FindFirst("UserId")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrWhiteSpace(userIdClaim))
                throw new Exception("UserId claim not found in token.");

            return Guid.Parse(userIdClaim);
        }
    }
}