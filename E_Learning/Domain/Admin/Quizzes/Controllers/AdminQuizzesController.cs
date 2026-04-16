using E_Learning.Domain.Admin.Quizzes.Dtos;
using E_Learning.Domain.Admin.Quizzes.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Admin.Quizzes.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminQuizzesController : ControllerBase
    {
        private readonly IAdminQuizService _quizService;

        public AdminQuizzesController(IAdminQuizService quizService)
        {
            _quizService = quizService;
        }

        [HttpGet("topics/{topicId:guid}/quizzes")]
        public async Task<IActionResult> GetByTopic(Guid topicId)
        {
            try
            {
                var result = await _quizService.GetByTopicAsync(topicId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpGet("quizzes/{quizId:guid}")]
        public async Task<IActionResult> GetById(Guid quizId)
        {
            try
            {
                var result = await _quizService.GetByIdAsync(quizId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost("topics/{topicId:guid}/quizzes")]
        public async Task<IActionResult> Create(Guid topicId, [FromBody] CreateQuizRequest request)
        {
            try
            {
                var result = await _quizService.CreateAsync(topicId, request);
                return CreatedAtAction(nameof(GetById), new { quizId = result.QuizId }, result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("quizzes/{quizId:guid}")]
        public async Task<IActionResult> Update(Guid quizId, [FromBody] UpdateQuizRequest request)
        {
            try
            {
                var result = await _quizService.UpdateAsync(quizId, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPatch("quizzes/{quizId:guid}/toggle-active")]
        public async Task<IActionResult> ToggleActive(Guid quizId, [FromBody] ToggleQuizActiveRequest request)
        {
            try
            {
                await _quizService.ToggleActiveAsync(quizId, request.IsActive);
                return Ok(new { message = "Quiz status updated successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpDelete("quizzes/{quizId:guid}")]
        public async Task<IActionResult> Delete(Guid quizId)
        {
            try
            {
                await _quizService.DeleteAsync(quizId);
                return Ok(new { message = "Quiz deleted successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
