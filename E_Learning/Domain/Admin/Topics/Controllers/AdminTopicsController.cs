using E_Learning.Domain.Admin.Topics.Dtos;
using E_Learning.Domain.Admin.Topics.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Admin.Topics.Controllers
{
    [ApiController]
    [Route("api/admin/topics")]
    [Authorize(Roles = "Admin")]
    public class AdminTopicsController : ControllerBase
    {
        private readonly IAdminTopicService _topicService;

        public AdminTopicsController(IAdminTopicService topicService)
        {
            _topicService = topicService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _topicService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{topicId:guid}")]
        public async Task<IActionResult> GetById(Guid topicId)
        {
            try
            {
                var result = await _topicService.GetByIdAsync(topicId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateTopicRequest request)
        {
            try
            {
                var result = await _topicService.CreateAsync(request);
                return CreatedAtAction(nameof(GetById), new { topicId = result.TopicId }, result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{topicId:guid}")]
        public async Task<IActionResult> Update(Guid topicId, [FromBody] UpdateTopicRequest request)
        {
            try
            {
                var result = await _topicService.UpdateAsync(topicId, request);
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

        [HttpPatch("{topicId:guid}/toggle-active")]
        public async Task<IActionResult> ToggleActive(Guid topicId, [FromBody] ToggleTopicActiveRequest request)
        {
            try
            {
                await _topicService.ToggleActiveAsync(topicId, request.IsActive);
                return Ok(new { message = "Topic status updated successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpDelete("{topicId:guid}")]
        public async Task<IActionResult> Delete(Guid topicId)
        {
            try
            {
                await _topicService.DeleteAsync(topicId);
                return Ok(new { message = "Topic deleted successfully." });
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